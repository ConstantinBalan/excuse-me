# Missing Systems - Detailed Implementation Breakdown

This document breaks down the unimplemented systems from the roadmap into specific, actionable tasks with implementation details.

---

## 🎯 **Phase A: Critical Missing Systems**

### 1. RunState Resource System
**File**: `Resources/Resource Scripts/run_state.gd`
**Purpose**: Central persistent game data that travels between scenes

```gdscript
# Implementation Structure Needed:
class_name RunState
extends Resource

# Player deck management
@export var deck: Array[CardStats] = []
@export var hand: Array[CardStats] = []

# Energy system (player health)
@export var global_energy: int = 100
@export var turn_energy: int = 3
@export var max_turn_energy: int = 3

# Progression tracking
@export var current_day: GameEnums.WeekDay = GameEnums.WeekDay.MONDAY
@export var current_week: int = 1
@export var current_day_section: GameEnums.DaySection = GameEnums.DaySection.WORK

# Game state
@export var completed_events: Array[String] = []
@export var unlocked_cards: Array[String] = []
```

**Implementation Tasks**:
- [ ] Create `Resources/Resource Scripts/run_state.gd` file
- [ ] Add `class_name RunState` declaration
- [ ] Extend `Resource` class for save/load support
- [ ] Add @export properties for deck, hand, discard_pile (all `Array[CardStats]`)
- [ ] Add @export properties: `global_energy: int = 100`, `turn_energy: int = 3`, `max_turn_energy: int = 3`
- [ ] Add @export properties: `current_day: GameEnums.WeekDay`, `current_week: int = 1`, `current_day_section: GameEnums.DaySection`
- [ ] Add @export properties: `completed_events: Array[String] = []`, `unlocked_cards: Array[String] = []`
- [ ] Implement `shuffle_deck() -> void` using `deck.shuffle()`
- [ ] Implement `draw_card() -> CardStats` (removes from deck, adds to hand, returns card or null)
- [ ] Implement `add_card_to_deck(card: CardStats, position: int = -1) -> void`
- [ ] Implement `remove_card_from_deck(card: CardStats) -> bool`
- [ ] Implement `discard_card(card: CardStats) -> void` (moves from hand to discard_pile)
- [ ] Implement `modify_global_energy(amount: int) -> void` with bounds checking (min: 0, max: 100)
- [ ] Implement `modify_turn_energy(amount: int) -> void` with bounds checking (min: 0, max: max_turn_energy)
- [ ] Implement `reset_turn_energy() -> void` (sets turn_energy back to max_turn_energy)
- [ ] Implement `advance_day() -> void` (increments day, handles week rollover)
- [ ] Implement `advance_day_section() -> void` (cycles through WORK → COMMUTE → HOME)
- [ ] Implement `clone_state() -> RunState` using `duplicate(true)` for state snapshots
- [ ] Add `mark_event_completed(event_id: String) -> void`
- [ ] Add `unlock_card(card_id: String) -> void`
- [ ] Add `is_event_completed(event_id: String) -> bool`

**Testing Tasks**:
- [ ] Create `test_scenes/test_run_state.gd` test scene
- [ ] Test: Draw 5 cards, verify deck size decreases and hand size increases
- [ ] Test: Shuffle deck, verify order changes
- [ ] Test: Modify global_energy to -50, verify it clamps to 0
- [ ] Test: Modify global_energy to 150, verify it clamps to 100
- [ ] Test: Reset turn energy after spending it, verify it returns to max
- [ ] Test: Advance through all day sections, verify proper cycling
- [ ] Test: Advance day from SUNDAY, verify week increments
- [ ] Test: Clone state, modify clone, verify original is unchanged
- [ ] Test: Mark events as completed, verify is_event_completed() returns true

---

### 2. LevelLoader with Dependency Injection
**File**: `systems/level_loader.gd`
**Purpose**: Scene management with RunState persistence

```gdscript
# Implementation Structure Needed:
class_name LevelLoader
extends Node

var current_scene: Node
var run_state: RunState

func load_encounter(scene_path: String) -> void
func inject_state_into_scene(scene: Node, state: RunState) -> void
func transition_to_scene(new_scene: Node) -> void
```

**Implementation Tasks**:
- [ ] Create `systems/` directory in project root
- [ ] Create `systems/level_loader.gd` file
- [ ] Add `class_name LevelLoader` declaration
- [ ] Extend `Node` class
- [ ] Add property: `var current_scene: Node = null`
- [ ] Add property: `var run_state: RunState = null`
- [ ] Add property: `var is_transitioning: bool = false`
- [ ] Implement `initialize(starting_state: RunState) -> void` to set initial run_state
- [ ] Implement `load_scene(scene_path: String) -> void` using `ResourceLoader.load(scene_path).instantiate()`
- [ ] Implement `inject_state_into_scene(scene: Node) -> void` (calls scene.inject_state(run_state) if method exists)
- [ ] Implement `unload_current_scene() -> void` (queue_free current_scene, set to null)
- [ ] Implement `transition_to_scene(scene_path: String, fade_duration: float = 0.5) -> void`
- [ ] Create `ColorRect` overlay for fade transitions (black, full screen)
- [ ] Implement fade-out animation using `Tween`
- [ ] Add scene switch logic: unload old → load new → inject state → add to tree
- [ ] Implement fade-in animation
- [ ] Add error handling for missing scenes (print error, don't crash)
- [ ] Emit signal when transition completes (create custom signal `transition_completed`)
- [ ] Add `get_current_state() -> RunState` method to retrieve run_state reference

**Testing Tasks**:
- [ ] Create `test_scenes/test_level_loader.tscn` with LevelLoader node
- [ ] Create two simple test scenes: `test_scene_a.tscn` and `test_scene_b.tscn`
- [ ] Add `inject_state()` method to both test scenes that prints run_state data
- [ ] Test: Initialize LevelLoader with a test RunState
- [ ] Test: Load scene A, verify inject_state() is called and run_state is passed
- [ ] Test: Transition from scene A to scene B, verify fade works
- [ ] Test: Verify scene A is freed from memory after transition
- [ ] Test: Modify run_state in scene B, transition back to scene A, verify changes persist
- [ ] Test: Try loading invalid scene path, verify error handling doesn't crash

---

### 3. HandManager System
**File**: `game_objects/hand_manager/hand_manager.gd`
**Purpose**: Bridge between RunState and Card UI system

```gdscript
# Implementation Structure Needed:
class_name HandManager
extends Node

@onready var hand_container: HBoxContainer
var run_state: RunState
var current_hand: Array[CardStats] = []

func draw_starting_hand() -> void
func play_card(card: CardStats, target: EventEntity) -> void
func add_card_to_hand(card: CardStats) -> void
func remove_card_from_hand(card: CardStats) -> void
func refresh_hand_ui() -> void
```

**Implementation Tasks**:
- [ ] Create `game_objects/hand_manager/` directory
- [ ] Create `game_objects/hand_manager/hand_manager.gd` file
- [ ] Add `class_name HandManager` declaration
- [ ] Extend `Node` class
- [ ] Add property: `@onready var hand_container: HBoxContainer` (link to scene node)
- [ ] Add property: `var run_state: RunState = null`
- [ ] Add property: `const STARTING_HAND_SIZE: int = 5`
- [ ] Add property: `const MAX_HAND_SIZE: int = 10`
- [ ] Add property: `var card_ui_scene: PackedScene` (preload CardUI scene)
- [ ] Implement `inject_state(state: RunState) -> void` to receive run_state reference
- [ ] Implement `draw_starting_hand() -> void` (draws STARTING_HAND_SIZE cards)
- [ ] Implement `draw_cards(count: int) -> void` (loops and calls draw_single_card())
- [ ] Implement `draw_single_card() -> void` (calls run_state.draw_card(), creates CardUI, adds to container)
- [ ] Implement `create_card_ui(card: CardStats) -> CardUI` (instantiate scene, set card data)
- [ ] Implement `add_card_to_hand_ui(card: CardStats) -> void` (creates UI, adds to container)
- [ ] Implement `remove_card_from_hand_ui(card_ui: CardUI) -> void` (removes from container, queue_free)
- [ ] Implement `play_card(card: CardStats, target: EventEntity) -> void` (removes from hand, creates PlayCardCommand)
- [ ] Implement `refresh_hand_ui() -> void` (clears all CardUI nodes, recreates from run_state.hand)
- [ ] Add hand size check in draw_single_card() (don't draw if at MAX_HAND_SIZE)
- [ ] Connect CardUI drag-drop signals to play_card() method
- [ ] Implement `can_afford_card(card: CardStats) -> bool` (check run_state.turn_energy >= card.cost)
- [ ] Update CardUI visual state based on can_afford_card() (grey out unaffordable cards)
- [ ] Create `game_objects/hand_manager/hand_manager.tscn` scene
- [ ] Add HBoxContainer node for card layout
- [ ] Set HBoxContainer alignment and spacing properties

**Testing Tasks**:
- [ ] Create `test_scenes/test_hand_manager.tscn` scene
- [ ] Add HandManager node with HBoxContainer child
- [ ] Create test RunState with 10 test cards in deck
- [ ] Test: Draw starting hand (5 cards), verify 5 CardUI nodes appear
- [ ] Test: Draw cards when hand is at MAX_HAND_SIZE, verify it stops drawing
- [ ] Test: Play a card, verify it's removed from hand_container
- [ ] Test: Set turn_energy to 0, verify expensive cards are greyed out
- [ ] Test: Refresh hand UI, verify all cards are recreated correctly
- [ ] Test: Draw until deck is empty, verify graceful handling (no crash)

---

### 4. BattleState System
**File**: `game_objects/battle_state/battle_state.gd`  
**Purpose**: Turn-based combat state machine

```gdscript
# Implementation Structure Needed:
class_name BattleState
extends Node

enum TurnPhase { PLAYER_TURN, RESOLUTION, ENEMY_TURN }

var current_phase: TurnPhase = TurnPhase.PLAYER_TURN
var current_event: EventInstance
var hand_manager: HandManager
var run_state: RunState

func start_player_turn() -> void
func process_card_play(card: CardStats) -> void  
func start_enemy_turn() -> void
func check_win_loss_conditions() -> void
```

**Implementation Tasks**:
- [ ] Create `game_objects/battle_state/` directory
- [ ] Create `game_objects/battle_state/battle_state.gd` file
- [ ] Add `class_name BattleState` declaration
- [ ] Extend `Node` class
- [ ] Define `enum TurnPhase { PLAYER_TURN, RESOLUTION, ENEMY_TURN, VICTORY, DEFEAT }`
- [ ] Add property: `var current_phase: TurnPhase = TurnPhase.PLAYER_TURN`
- [ ] Add property: `var run_state: RunState = null`
- [ ] Add property: `var current_event: EventEntity = null`
- [ ] Add property: `@onready var hand_manager: HandManager` (reference to scene node)
- [ ] Add signals: `signal phase_changed(new_phase: TurnPhase)`
- [ ] Add signals: `signal battle_won`, `signal battle_lost`
- [ ] Implement `inject_state(state: RunState, event: EventEntity) -> void` to receive game state
- [ ] Implement `start_battle() -> void` (initializes battle, calls start_player_turn())
- [ ] Implement `start_player_turn() -> void` (sets phase, resets turn energy, draws cards)
- [ ] Implement `end_player_turn() -> void` (sets phase to RESOLUTION)
- [ ] Implement `process_resolution_phase() -> void` (waits for CommandQueue to finish)
- [ ] Implement `start_enemy_turn() -> void` (event plays its action, applies damage to player)
- [ ] Implement `end_enemy_turn() -> void` (checks win/loss, starts new player turn or ends battle)
- [ ] Implement `check_win_condition() -> bool` (returns true if current_event.integrity <= 0)
- [ ] Implement `check_loss_condition() -> bool` (returns true if run_state.global_energy <= 0)
- [ ] Implement `handle_victory() -> void` (set phase to VICTORY, emit battle_won signal)
- [ ] Implement `handle_defeat() -> void` (set phase to DEFEAT, emit battle_lost signal)
- [ ] Connect to CommandQueue.all_commands_finished signal for resolution phase
- [ ] Create UI button: "End Turn" that calls end_player_turn()
- [ ] Add turn counter: `var turn_count: int = 0`
- [ ] Increment turn_count at start of each player turn
- [ ] Create `game_objects/battle_state/battle_state.tscn` scene with UI elements
- [ ] Add Label for phase display (e.g., "Player Turn", "Enemy Turn")
- [ ] Add Label for turn counter display
- [ ] Implement phase transition animations (fade/slide effects on phase change)

**Testing Tasks**:
- [ ] Create `test_scenes/test_battle_state.tscn` scene
- [ ] Add BattleState node with HandManager child
- [ ] Create test RunState with starter deck
- [ ] Create test EventEntity with 10 integrity
- [ ] Test: Start battle, verify phase is PLAYER_TURN
- [ ] Test: Verify starting hand is drawn (5 cards)
- [ ] Test: Play cards that reduce event integrity to 0, verify VICTORY phase triggers
- [ ] Test: Reduce player global_energy to 0, verify DEFEAT phase triggers
- [ ] Test: End turn, verify phase transitions: PLAYER_TURN → RESOLUTION → ENEMY_TURN → PLAYER_TURN
- [ ] Test: Verify turn counter increments each round
- [ ] Test: Verify turn energy resets at start of player turn

---

## 🔧 **Phase B: Integration Tasks**

### 5. CommandQueue Integration
**Current**: Command system exists but not connected
**Needed**: Wire into autoloads and card system

**Implementation Tasks**:
- [ ] Open `project.godot` in text editor
- [ ] Add to autoload section: `CommandQueue="*res://autoloads/CommandQueue/command_queue.gd"`
- [ ] Verify CommandQueue autoload appears in Project Settings → Autoload
- [ ] Create `autoloads/CommandQueue/play_card_command.gd` file
- [ ] Make PlayCardCommand extend existing Command base class
- [ ] Add properties to PlayCardCommand: `var card: CardStats`, `var target: EventEntity`, `var calculator: CardPlayedCalculator`
- [ ] Implement `execute() -> void` method that calls calculator.calculate_and_apply_impact(card, target)
- [ ] Add visual feedback: emit signal when command starts/completes
- [ ] In HandManager.play_card(), create PlayCardCommand and call CommandQueue.add_command()
- [ ] Connect CommandQueue.all_commands_finished signal to BattleState.process_resolution_phase()
- [ ] Add debug prints to track command execution order

**Testing Tasks**:
- [ ] Test: Verify CommandQueue is accessible globally (print CommandQueue from any script)
- [ ] Test: Play a card, verify PlayCardCommand is created and added to queue
- [ ] Test: Play 3 cards in sequence, verify they execute in order
- [ ] Test: Verify all_commands_finished signal fires after queue is empty
- [ ] Test: Play card with visual effect, verify command waits for effect before completing

---

### 6. Enhanced EventEntity
**Current**: Basic integrity tracking exists
**Needed**: Visual representation and zone integration

**Implementation Tasks**:
- [ ] Open `game_objects/event_entity/event_entity.gd`
- [ ] Change inheritance from `extends Node` to `extends Node2D`
- [ ] Add property: `@export var context_type: GameEnums.DaySection = GameEnums.DaySection.WORK`
- [ ] Add property: `@onready var health_bar: ProgressBar` (reference to UI element)
- [ ] Add property: `@onready var damage_label: Label` (for damage numbers)
- [ ] Add property: `@onready var sprite: Sprite2D` (event visual representation)
- [ ] Implement `update_health_bar() -> void` (sets ProgressBar value to current integrity)
- [ ] Implement `take_damage(amount: int) -> void` (reduces integrity, updates UI, plays animation)
- [ ] Implement `show_damage_number(amount: int) -> void` (animates damage label with Tween)
- [ ] Implement `play_damage_animation() -> void` (shake/flash sprite)
- [ ] Implement `play_death_animation() -> void` (fade out, emit destroyed signal)
- [ ] Add signal: `signal integrity_changed(new_value: int)`
- [ ] Add signal: `signal destroyed()`
- [ ] Update EventEntity scene (.tscn) to include Sprite2D, ProgressBar, Label nodes
- [ ] Connect integrity changes to health_bar updates
- [ ] Create damage shake animation using Tween (move sprite +/- 5 pixels)
- [ ] Create flash animation (modulate sprite red for 0.2 seconds)

**Testing Tasks**:
- [ ] Create `test_scenes/test_event_entity.tscn` with EventEntity
- [ ] Set up test EventEntity with 50 integrity
- [ ] Test: Call take_damage(10), verify health bar updates to 40/50
- [ ] Test: Verify damage number "-10" appears and floats upward
- [ ] Test: Verify sprite shakes on damage
- [ ] Test: Reduce integrity to 0, verify death animation plays
- [ ] Test: Verify destroyed signal emits after death animation
- [ ] Test: Set context_type to different DaySection values, verify property saves correctly

---

### 7. Zone Preference System
**Current**: CardStats may have preferred_zone, EventEntity needs context_type
**Needed**: 1.5x bonus calculation in CardPlayedCalculator

**Implementation Tasks**:
- [ ] Open `Resources/Resource Scripts/card_stats.gd`
- [ ] Verify `@export var preferred_zone: GameEnums.DaySection` property exists (add if missing)
- [ ] Open `game_objects/card_played_calculator/card_played_calculator.gd`
- [ ] Locate `calculate_impact()` or similar method
- [ ] Add zone bonus check at start of impact calculation
- [ ] Implement logic: `if card.preferred_zone == event.context_type: base_impact = int(base_impact * 1.5)`
- [ ] Add visual feedback for zone bonus (emit signal or return bonus info)
- [ ] Create zone bonus icon/indicator on CardUI when in preferred zone
- [ ] Add property to CardUI: `var is_in_preferred_zone: bool = false`
- [ ] Implement `update_zone_status(current_zone: GameEnums.DaySection) -> void` in CardUI
- [ ] Add visual highlight (glow/border) to cards in their preferred zone
- [ ] Update card tooltip to show zone bonus information

**Testing Tasks**:
- [ ] Create test cards with different preferred_zones (WORK, COMMUTE, HOME)
- [ ] Create test EventEntity with context_type = WORK
- [ ] Test: Play WORK-preferred card against WORK event, verify 1.5x damage
- [ ] Test: Play COMMUTE-preferred card against WORK event, verify normal damage
- [ ] Test: Verify visual indicator appears on cards in preferred zone
- [ ] Test: Create card with base_impact = 10, preferred_zone = HOME, play against HOME event, verify 15 damage dealt
- [ ] Test: Verify zone bonus rounds correctly (int casting)

---

### 8. Day Manager → Battle Integration
**Current**: DayManager generates events but no battle resolution
**Needed**: Bridge between event generation and battle system

**Implementation Tasks**:
- [ ] Open `game_objects/day_manager/day_manager.gd`
- [ ] Add property: `var level_loader: LevelLoader` (reference to global/scene loader)
- [ ] Locate `display_next_event()` method
- [ ] Replace current event display logic with battle scene transition
- [ ] Implement `start_battle_for_event(event: EventInstance) -> void`
- [ ] Call `level_loader.transition_to_scene("res://Main Scenes/battle_encounter.tscn")`
- [ ] Store current event reference to pass to battle scene
- [ ] Create `Main Scenes/battle_encounter.tscn` scene
- [ ] Add BattleState node as root
- [ ] Add HandManager, EventEntity, and UI elements to battle scene
- [ ] Implement `inject_state(run_state: RunState, event: EventEntity)` in battle scene
- [ ] Connect BattleState.battle_won signal to `on_battle_won()` in DayManager
- [ ] Connect BattleState.battle_lost signal to `on_battle_lost()` in DayManager
- [ ] Implement `on_battle_won() -> void` (mark event complete, transition back to day view)
- [ ] Implement `on_battle_lost() -> void` (trigger game over or retry logic)
- [ ] Update RunState.completed_events when battle is won
- [ ] Transition back to DayManager scene after battle completion
- [ ] Implement rewards system: add card unlocks or energy bonuses on victory

**Testing Tasks**:
- [ ] Test: Generate an event in DayManager, verify battle scene loads
- [ ] Test: Verify event data (integrity, description) is passed to battle scene correctly
- [ ] Test: Win a battle, verify return to DayManager with event marked complete
- [ ] Test: Lose a battle, verify game over screen appears
- [ ] Test: Complete 3 events in sequence, verify day progression works
- [ ] Test: Verify RunState persists between DayManager ↔ Battle transitions
- [ ] Test: Check that completed events don't reappear

---

## 🎨 **Phase C: Polish & Features**

### 9. Panic Mechanic
**File**: Add to BattleState or HandManager
**Purpose**: Emergency hand refresh at cost

**Implementation Tasks**:
- [ ] Open `game_objects/hand_manager/hand_manager.gd`
- [ ] Add constant: `const PANIC_COST: int = 2` (global energy cost)
- [ ] Implement `can_panic() -> bool` (check if run_state.global_energy >= PANIC_COST)
- [ ] Implement `execute_panic() -> void` method
- [ ] In execute_panic(): discard all cards in hand to discard_pile
- [ ] Call run_state.modify_global_energy(-PANIC_COST)
- [ ] Draw 5 new cards using draw_cards(5)
- [ ] Emit signal `panic_activated` for visual feedback
- [ ] Open battle_encounter.tscn scene
- [ ] Add Button node labeled "Panic" to battle UI
- [ ] Connect button pressed signal to `on_panic_button_pressed()`
- [ ] Implement `on_panic_button_pressed() -> void` (checks can_panic, calls execute_panic)
- [ ] Disable Panic button when global_energy < PANIC_COST
- [ ] Add visual feedback: screen shake using Camera2D
- [ ] Add visual feedback: red flash overlay (ColorRect with Tween)
- [ ] Add sound effect for panic activation
- [ ] Update UI to show panic cost on button ("Panic (-2 Energy)")

**Testing Tasks**:
- [ ] Test: Start battle with global_energy = 10, click Panic, verify energy drops to 8
- [ ] Test: Verify all 5 cards in hand are discarded
- [ ] Test: Verify 5 new cards are drawn from deck
- [ ] Test: Set global_energy to 1, verify Panic button is disabled
- [ ] Test: Use Panic when deck has < 5 cards remaining, verify graceful handling
- [ ] Test: Verify screen shake and red flash animations play on Panic
- [ ] Test: Use Panic multiple times in one battle, verify energy cost applies each time

---

### 10. Test Content Creation
**Purpose**: Minimal viable content for testing

**Implementation Tasks**:
- [ ] Create `Resources/Card Types/Test Cards/` directory
- [ ] Create card 1: "Coffee Break" - WORK zone, 5 damage, 1 cost
- [ ] Create card 2: "Traffic Excuse" - COMMUTE zone, 7 damage, 2 cost
- [ ] Create card 3: "Family Emergency" - HOME zone, 6 damage, 2 cost
- [ ] Create card 4: "Technical Difficulties" - WORK zone, 4 damage, 1 cost
- [ ] Create card 5: "Feeling Unwell" - any zone, 8 damage, 3 cost
- [ ] Save each as `.tres` file in Test Cards directory
- [ ] Create `Resources/Events/Test Events/` directory
- [ ] Create event 1: "Urgent Meeting" - WORK context, 30 integrity
- [ ] Create event 2: "Rush Hour Traffic" - COMMUTE context, 25 integrity
- [ ] Create event 3: "Household Chore" - HOME context, 20 integrity
- [ ] Save each event as `.tres` file
- [ ] Create `test_scenes/test_starter_deck.tres` RunState resource
- [ ] Add 10 copies of test cards to starter deck (mix of all 5 cards)
- [ ] Set initial global_energy = 20, turn_energy = 3
- [ ] Update battle_encounter.tscn to use test event by default
- [ ] Create simple main menu scene: `Main Scenes/main_menu.tscn`
- [ ] Add "Start Game" button that loads test battle
- [ ] Add "Quit" button that calls get_tree().quit()
- [ ] Create game flow: Main Menu → Battle → Victory/Defeat → Main Menu

**Testing Tasks**:
- [ ] Test: Start from main menu, verify Start Game button works
- [ ] Test: Load battle with "Urgent Meeting" event (WORK context)
- [ ] Test: Play "Coffee Break" card, verify 1.5x bonus (7-8 damage)
- [ ] Test: Play "Traffic Excuse" card, verify normal damage (7 damage)
- [ ] Test: Defeat event with 30 integrity using test cards
- [ ] Test: Verify victory screen appears after event defeated
- [ ] Test: Return to main menu after victory
- [ ] Test: Verify all 5 test cards have unique art/descriptions
- [ ] Test: Play through full battle using only starter deck, verify winnable

---

## 📋 **Implementation Priority Order**

### Recommended Implementation Sequence:

**Sprint 1: Core Foundation (Complete & Test Before Moving On)**
1. **RunState** - Foundational data structure required by all systems
   - Complete all Implementation Tasks
   - Complete all Testing Tasks
   - Verify all tests pass before continuing

2. **CommandQueue Integration** - Required for card actions
   - Complete all Implementation Tasks
   - Complete all Testing Tasks
   - Verify command execution works correctly

**Sprint 2: Card & Battle Systems (Complete & Test Before Moving On)**
3. **HandManager** - Card UI and interaction
   - Complete all Implementation Tasks
   - Complete all Testing Tasks
   - Verify cards can be drawn and displayed

4. **Enhanced EventEntity** - Visual enemy representation
   - Complete all Implementation Tasks
   - Complete all Testing Tasks
   - Verify damage animations work

5. **Zone Preference System** - Core gameplay mechanic
   - Complete all Implementation Tasks
   - Complete all Testing Tasks
   - Verify bonus damage calculations

**Sprint 3: Battle Flow (Complete & Test Before Moving On)**
6. **BattleState** - Turn-based combat loop
   - Complete all Implementation Tasks
   - Complete all Testing Tasks
   - Verify full turn cycle works (Player → Resolution → Enemy)

7. **Test Content Creation** - Playable content for validation
   - Complete all Implementation Tasks
   - Complete all Testing Tasks
   - Ensure at least one full battle can be won

**Sprint 4: Scene Integration (Complete & Test Before Moving On)**
8. **LevelLoader** - Scene transitions with state persistence
   - Complete all Implementation Tasks
   - Complete all Testing Tasks
   - Verify state persists across scene changes

9. **Day Manager Integration** - Connect day loop to battles
   - Complete all Implementation Tasks
   - Complete all Testing Tasks
   - Verify full loop: Day → Battle → Victory → Day

**Sprint 5: Polish (Optional, Can Be Incremental)**
10. **Panic Mechanic** - Emergency gameplay option
    - Complete all Implementation Tasks
    - Complete all Testing Tasks
    - Verify panic doesn't break game state

---

## 🧪 **Testing Strategy**

### Per-System Testing
- After completing each system's implementation tasks, **immediately** run all associated testing tasks
- Do NOT move to the next system until all tests pass
- Document any bugs found and fix them before proceeding

### Integration Testing
- After each Sprint, run integration tests across all completed systems
- Create a test scene that uses all Sprint systems together
- Verify no regressions from previous Sprints

### Milestone Testing
- **Milestone 1** (After Sprint 2): Can draw and play cards with visual feedback
- **Milestone 2** (After Sprint 3): Can complete a full battle from start to victory/defeat
- **Milestone 3** (After Sprint 4): Can transition between day view and battle, state persists
- **Milestone 4** (After Sprint 5): Full game loop with all features functional

### Acceptance Criteria for Completion
- [ ] All implementation tasks completed for all systems
- [ ] All testing tasks pass for all systems
- [ ] No critical bugs or crashes
- [ ] Can play from main menu through complete battle and back to menu
- [ ] RunState correctly persists across scene transitions
- [ ] Zone bonus system works and provides strategic depth