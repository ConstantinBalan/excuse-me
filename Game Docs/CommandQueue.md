# CommandQueue (The Timekeeper)

## Purpose

The `CommandQueue` is a critical system for managing game actions and their visual feedback. Its primary purpose is to decouple immediate game logic calculations from time-based visual executions (like animations or particle effects). This prevents race conditions where game data might update before visuals complete, leading to desynchronization and a poor player experience.

It operates on a Command Pattern, processing one action at a time and awaiting its visual completion before moving to the next.

## Implementation Details

-   **Queue (`_queue`):** An array storing `Command` objects.
-   **Processing Flag (`_is_processing`):** A boolean to prevent multiple concurrent processing loops.
-   **`add_command(cmd: Command)`:** Appends a new command to the queue and initiates processing if not already active.
-   **`_process_queue()`:** Iterates through the queue, executes each command's logic and visuals, and `await`s its completion signal.
-   **`_safe_wait(cmd: Command)`:** A utility function that waits for a command's `finished` signal or a safety timeout (2.0 seconds) to prevent soft-locks if an animation fails to emit its signal.

## File Locations

-   `res://systems/command_queue/command_queue.gd`
-   `res://systems/command_queue/command.gd` (Base Class)

## GDScript Example: `command_queue.gd`

```gdscript
class_name CommandQueue extends Node

var _queue: Array[Command] = []
var _is_processing: bool = false

func add_command(cmd: Command) -> void:
    _queue.append(cmd)
    if not _is_processing: _process_queue()

func _process_queue() -> void:
    if _queue.is_empty():
        _is_processing = false
        return
    _is_processing = true
    var cmd = _queue.pop_front()
    
    # 1. Execute Logic & Visuals
    cmd.execute()
    
    # 2. Wait for completion (with safety timeout)
    await _safe_wait(cmd)
    
    # 3. Next
    _process_queue()

func _safe_wait(cmd: Command) -> void:
    if cmd.is_finished: return
    var timer = get_tree().create_timer(2.0)
    while not cmd.is_finished and timer.time_left > 0:
        await get_tree().process_frame
```

## GDScript Example: `command.gd` (Base Class)

```gdscript
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
```