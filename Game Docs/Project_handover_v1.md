Project Handover: "Excuse Me" Development
Date: October 2025 Engine: Godot 4.x (GDScript) Team: 1 Senior (Architect/Navigator), 1 Junior (Implementer/Driver)

1. Project Context
Excuse Me is a single-player deckbuilder survival game where the player manages social obligations using a deck of "Excuses."

Core Loop: Weekly survival (Mon-Fri). Manage Energy (HP) vs. Social Obligations (Enemies).

Tone: Social anxiety, humor, everyday horror.

Key Mechanics:

Energy as Currency: Playing cards costs Energy. Running out of Energy = Burnout (Loss).

Archetypes: Avoider (Stall), Oversharer (Self-mill/High Risk), Liar (Combo/Tagging).

Events: Non-combat "Enemies" (Boss, Mom, Landlord).

2. Production Protocols
The "No-Typing" Rule: The Senior Dev (Dragos) designs and reviews but never types. The Junior Dev (Dani) drives the implementation.

Feature Sets: Work is divided into vertical slices (e.g., "The Commute Phase") rather than horizontal layers (e.g., "All UI").

3. Core Architecture: The "Entity" Abstraction
Addressing the design challenge: "How do Card Effects work if enemies don't have health?"

In this architecture, we treat Events exactly like Enemies, but we alias the data fields to match the context. We use a system called Contextual Attribute Mapping.

The EventEntity Concept
Every Event (The Boss, A Traffic Jam, A Crying Friend) is an instance of EventEntity. Instead of Health, they have Integrity.

Integrity: How much "effort" or "convincing" is needed to resolve the event.

Combat Context: Integrity = HP.

Social Context: Integrity = Suspicion / Stubbornness.

Task Context: Integrity = Complexity.

The Card Logic
Cards do not deal "Damage"; they deal Impact.

Card: "White Lie" -> Deals 5 Impact.

Target (Boss): 50 Integrity (Suspicion).

Result: Boss Integrity drops to 45.

Visuals: The Boss "frowns" (Hurt animation).

If the Integrity reaches 0, the player has successfully "excused" themselves from the situation.

4. System Implementation Logic
A. The CommandQueue (Deterministic Turn Resolution)
Purpose: Decouples game logic (instant) from visual feedback (time-based). Solves race conditions where animations desync from data.

File: res://systems/command_queue/command_queue.gd

GDScript

class_name CommandQueue
extends Node

# The queue acts as a "Traffic Controller" for actions.
var _queue: Array[Command] =
var _is_processing: bool = false

func add_command(command: Command) -> void:
    _queue.append(command)
    if not _is_processing:
        _process_next()

func _process_next() -> void:
    if _queue.is_empty():
        _is_processing = false
        return
    
    _is_processing = true
    var current_command = _queue.pop_front()
    
    # 1. Trigger the logic and visuals
    current_command.execute()
    
    # 2. Await the visual completion signal
    # We use a safety wrapper to prevent soft-locks if an animation fails
    await _safe_await(current_command)
    
    # 3. Recursive call
    _process_next()

func _safe_await(cmd: Command) -> void:
    if cmd.is_finished: return
    
    # Wait for the command to emit "finished" OR for a 3-second safety timer
    var timer = get_tree().create_timer(3.0)
    while not cmd.is_finished and timer.time_left > 0:
        await get_tree().process_frame
File: res://systems/command_queue/command.gd (Base Class)

GDScript

class_name Command
extends RefCounted

signal finished()
var is_finished: bool = false

func execute() -> void:
    _execute_logic()
    _execute_visuals()

# Data Logic (Instant) - e.g., "Reduce Integrity by 5"
func _execute_logic() -> void:
    pass

# Visual Logic (Async) - e.g., "Play particle effect"
func _execute_visuals() -> void:
    # Default behavior: finish immediately if no visuals defined
    call_deferred("emit_signal", "finished") 
B. The LevelLoader (Dependency Injection)
Purpose: Preserves the RunState (Deck, Energy, Relics) when switching scenes. prevents using fragile Global Singletons for player data.

File: res://systems/level_loader.gd

GDScript

extends Node

# The "Truth" of the current run. Persists between scenes.
var current_run_state: RunState 

func load_event_scene(scene_path: String) -> void:
    # 1. Background load the new scene
    ResourceLoader.load_threaded_request(scene_path)
    
    # 2. Wait for load (Simplified for brevity)
    # In production: Use a loop to check load_threaded_get_status
    var new_scene_packed = ResourceLoader.load_threaded_get(scene_path)
    var new_scene_instance = new_scene_packed.instantiate()
    
    # 3. INJECTION STEP
    # Before adding to the tree, we give the scene the data it needs.
    if new_scene_instance.has_method("setup_data"):
        new_scene_instance.setup_data(current_run_state)
    
    # 4. Swap scenes
    get_tree().root.add_child(new_scene_instance)
    get_tree().current_scene.queue_free()
    get_tree().current_scene = new_scene_instance
File: res://data/run_state.gd (Resource)

GDScript

class_name RunState
extends Resource

@export var current_deck: Array
@export var current_energy: int
@export var max_energy: int
@export var active_relics: Array
C. The Hierarchical Finite State Machine (HFSM)
Purpose: Manages the complex flow of Week -> Day -> Encounter -> Turn. We use Node-Based States so we can see the current state in the Remote Scene Tree while debugging.

Scene Tree Structure: GameController └── StateMachine ├── WeekLoopState │ ├── MondayState │ └──... ├── DayLoopState │ ├── CommuteState │ ├── WorkState │ └── HomeState └── EncounterState ├── PlayerTurn ├── Resolution (Wait for CommandQueue) └── EnemyTurn

File: res://systems/fsm/state_machine.gd

GDScript

class_name StateMachine
extends Node

var current_state: State

func change_state(new_state: State) -> void:
    if current_state:
        current_state.exit()
    
    current_state = new_state
    current_state.enter()

# Pass inputs down to the active state only
func _unhandled_input(event) -> void:
    if current_state:
        current_state.handle_input(event)
File: res://systems/fsm/state.gd (Base Class)

GDScript

class_name State
extends Node

# Reference to the controller (injected at runtime)
var game_controller: GameController 

func enter() -> void: pass
func exit() -> void: pass
func update(delta: float) -> void: pass
func handle_input(event: InputEvent) -> void: pass
Example Logic: ResolutionState This state bridges the Turn Logic and the Command Queue.

GDScript

# resolution_state.gd
extends State

func enter() -> void:
    # 1. Lock UI
    game_controller.ui_layer.disable_interactions()
    
    # 2. Wait for all queued animations (Attacks, Card Draws) to finish
    await game_controller.command_queue.queue_empty_signal
    
    # 3. Check Game Over or Turn End conditions
    if game_controller.player.energy <= 0:
        state_machine.change_state(game_controller.states.burnout)
    else:
        state_machine.change_state(game_controller.states.enemy_turn)
5. Next Steps for AI Assistant
Refine CardStats: Add the effects: Array[CardEffect] property to allow modular ability construction.

Implement EventEntity: Create the base node that acts as the "Enemy" but uses "Integrity" instead of Health.

Draft the UI: Connect EventBus signals to a HealthBar (EnergyBar) to prove the architecture works.