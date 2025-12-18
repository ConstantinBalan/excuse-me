# LevelLoader (Dependency Injection)

## Purpose

The `LevelLoader` is responsible for handling scene transitions while ensuring that the `RunState` (player's persistent data like deck, health, and current day) is correctly preserved and injected into the new scene. This pattern, known as Resource Injection or Dependency Injection, prevents the use of fragile Global Singletons, which can lead to tight coupling and difficult-to-manage state across different parts of the game.

## Implementation Details

-   **`load_encounter(scene_path: String, run_state: RunState)`:** This method orchestrates the loading process.
    1.  **Load Scene in Memory:** The target scene (e.g., an encounter scene) is loaded into memory as a `PackedScene` and then instantiated.
    2.  **INJECT DATA:** Crucially, before the new scene is added to the scene tree, the `LevelLoader` checks if the new scene instance has an `inject_state` method. If it does, the `run_state` resource is passed to this method. This allows the newly loaded scene to be initialized with the necessary persistent data.
    3.  **Switch Scene Tree:** The current scene is freed, and the new scene is added to the root of the scene tree, becoming the active scene.

## File Location

`res://systems/level_loader.gd`

## GDScript Example

```gdscript
extends Node

var _current_scene: Node # Keep track of the current scene to free it

func _ready():
    # Initialize _current_scene to the first scene when the LevelLoader is ready
    # This assumes LevelLoader is an autoloaded singleton or part of the initial scene tree
    _current_scene = get_tree().current_scene

func load_encounter(scene_path: String, run_state: RunState) -> void:
    # 1. Load Scene in Memory
    var next_scene = load(scene_path).instantiate()
    
    # 2. INJECT DATA (Crucial Step)
    if next_scene.has_method("inject_state"):
        next_scene.inject_state(run_state)
    
    # 3. Switch Scene Tree
    _current_scene.queue_free()
    get_tree().root.add_child(next_scene)
    _current_scene = next_scene
```