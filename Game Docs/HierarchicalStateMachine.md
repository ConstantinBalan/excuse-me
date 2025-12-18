# Hierarchical State Machine (The Brain)

## Purpose

The Hierarchical Finite State Machine (HFSM) is designed to manage the complex flow of the game, breaking it down into a structured hierarchy of states. This approach allows for clear organization of game logic, preventing spaghetti code and making debugging easier, especially when observing the current state in the Remote Scene Tree during development. It handles transitions between major game phases like the week, day, encounters, and individual turns.

## Structure

The HFSM organizes states in a tree-like hierarchy, allowing for parent states to manage common logic while child states handle specific behaviors. The proposed structure is:

```
GameController
└── StateMachine
    ├── WeekLoopState (Tracks Mon-Fri)
    │   ├── MondayState
    │   └── ...
    ├── DayLoopState (Tracks Morning/Commute/Work/Home)
    │   ├── CommuteState
    │   ├── WorkState
    │   └── HomeState
    └── BattleState (The actual card game)
        ├── PlayerTurn
        ├── Resolution (Wait for CommandQueue)
        └── EnemyTurn
```

## Implementation Details

-   **`StateMachine`:** The central node that manages state transitions. It holds a reference to the `current_state` and handles changing between different `State` nodes.
-   **`State` (Base Class):** An abstract base class for all state nodes. It provides common methods like `enter()`, `exit()`, `update(delta)`, and `handle_input(event)`, which are overridden by concrete state implementations. It also includes an injected reference to the `GameController`.
-   **Node-Based States:** Each state is implemented as a separate `Node` (or scene), allowing for visual debugging in the remote scene tree.

## File Locations

-   `res://systems/fsm/state_machine.gd`
-   `res://systems/fsm/state.gd` (Base Class)

## GDScript Example: `state_machine.gd`

```gdscript
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
```

## GDScript Example: `state.gd` (Base Class)

```gdscript
class_name State
extends Node

# Reference to the controller (injected at runtime)
var game_controller: GameController 

func enter() -> void: pass
func exit() -> void: pass
func update(delta: float) -> void: pass
func handle_input(event: InputEvent) -> void: pass
```

## Example Logic: `ResolutionState`

This state acts as a bridge between the instant turn logic and the asynchronous visual feedback managed by the `CommandQueue`.

```gdscript
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
```