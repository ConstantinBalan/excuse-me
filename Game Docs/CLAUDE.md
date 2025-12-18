# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**"Excuse Me"** is a turn-based card game built in Godot 4.x where players use excuse cards to get out of work/home/commute situations. The game follows a week-based progression with a unified deck system and contextual card synergies.

## Development Commands

### Running the Game
- Open project in Godot 4.x editor
- Press F5 or click the play button
- Main scene: `uid://1lkvdd4df0p3` (configured in project.godot)

### Project Structure
```
/autoloads/           # Game-wide singletons (GameManager, GameSignals)
/game_objects/        # Core game components (cards, events, calculators)
/Resources/           # Data resources (.tres files and GDScript classes)
  /Card Types/        # Card definitions organized by category
  /Resource Scripts/  # GDScript resource classes
/Main Scenes/         # Major game scenes
/Game Docs/          # Comprehensive technical documentation
```

## Core Architecture

### Key Systems

**Autoloads (Global Singletons)**:
- `GameManager`: Save/load functionality
- `GameSignals`: Central signal hub for decoupled communication
- `GameEnums`: WeekDay, Weather, DaySection, Category, Severity enums

**CommandQueue Pattern**: Critical async system in `/autoloads/CommandQueue/`
- Decouples logic from visual execution 
- Prevents race conditions between card effects and animations
- Uses Command pattern with await for sequential processing

**Resource-Driven Content**:
- Cards: `CardStats` resources with impact, preferred_zone, effects, keywords
- Events: `EventStats` resources with integrity (HP), severity, effective keywords
- All content stored as `.tres` files for easy modification

**State Machine Architecture** (Documented, partially implemented):
```
WeekLoopState
  ↓
DayLoopState (Morning → Commute → Work → Home)
  ↓  
BattleState (Player Turn → Resolution → Event Response)
```

### Key Design Patterns

**Dependency Injection**: `LevelLoader` injects `RunState` into scenes rather than using fragile global state

**Zone-Based Strategy**: Cards have `preferred_zone` (Work/Commute/Home) for contextual bonuses

**Unified Deck System**: Single deck used across all encounters, not context-specific decks

## Important Code Conventions

### GDScript Patterns
- Use `class_name` declarations for reusable classes
- Resources inherit from `Resource` class for data persistence
- Signal-based communication via `GameSignals` autoload
- Prefer composition over inheritance for game objects

### Resource System
- `CardStats.gd`: Defines card properties (cost, category, severity, effects)
- `EventStats.gd`: Defines event properties (integrity/HP, effective keywords)
- `CardEffect.gd`: Base class for modular card effects

### State Management
- `RunState`: Persistent data (deck, health, day progression) passed between scenes
- No global singletons for game state - use dependency injection
- EventEntity/EventInstance pattern for runtime state management

## Critical Implementation Notes

### CommandQueue Usage
Always use CommandQueue for actions that affect game state:
```gdscript
var cmd = PlayCardCommand.new(card, target)
CommandQueue.add_command(cmd)
```

### Scene Transitions
Use LevelLoader with state injection:
```gdscript
func inject_state(run_state: RunState) -> void:
    # Inject persistent data into new scene
```

### Card Effect Processing
Effects are processed through `CardPlayedCalculator` which handles:
- Zone preference bonuses (1.5x multiplier for preferred zones)
- Keyword matching against event vulnerabilities
- Impact calculation and application

## Documentation Location

Comprehensive technical documentation in `/Game Docs/` including:
- `Project_Handover_v2.md`: Complete technical specification and implementation checklist
- Architectural diagrams and flow charts
- Detailed gameplay mechanics and systems design

## Current Development Status

- ✅ Core card/event resource system implemented
- ✅ CommandQueue and signal systems functional  
- ✅ Basic UI and drag-drop interactions
- 🔄 State machine implementation (documented, needs completion)
- 🔄 Full game loop integration (day progression, win/loss conditions)
- 📋 Implementation checklist available in Project_Handover_v2.md