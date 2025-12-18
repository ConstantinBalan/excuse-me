# RunState

## Purpose

The `RunState` is a `Resource` that serves as the single source of truth for the player's progress and persistent data throughout a game run. It is designed to be injected into scenes via the `LevelLoader`, preventing the need for fragile Global Singletons and ensuring data integrity across scene transitions.

## Structure

`RunState` contains critical player data, including:

-   `current_deck: Array`
-   `current_energy: int`
-   `max_energy: int`
-   `active_relics: Array`

## Usage (Dependency Injection)

When a new encounter scene is loaded, the `LevelLoader` instantiates the scene and, if the new scene has an `inject_state` method, passes the `current_run_state` instance to it. This allows the scene to access and modify the run's data without direct global access.

## File Location

`res://data/run_state.gd`

## GDScript Example

```gdscript
class_name RunState
extends Resource

@export var current_deck: Array
@export var current_energy: int
@export var max_energy: int
@export var active_relics: Array
```