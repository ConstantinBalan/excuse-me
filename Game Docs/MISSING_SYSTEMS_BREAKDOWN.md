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

**Tasks**:
- [ ] Create class with proper Resource inheritance
- [ ] Add deck management (add/remove cards, shuffle)
- [ ] Add energy tracking (global/turn energy with min/max bounds)
- [ ] Add progression state (day, week, section tracking)
- [ ] Add save/load serialization methods

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

**Tasks**:
- [ ] Create systems directory and LevelLoader class
- [ ] Implement scene loading with memory management
- [ ] Add `inject_state()` pattern for all battle scenes
- [ ] Create scene transition animations/effects
- [ ] Handle scene cleanup and resource management

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

**Tasks**:
- [ ] Create HandManager directory and class
- [ ] Implement card drawing from RunState.deck
- [ ] Create CardUI instantiation and positioning
- [ ] Connect to card drag-drop system
- [ ] Add hand size limits and overflow handling
- [ ] Integrate with turn energy system

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

**Tasks**:
- [ ] Create BattleState directory and class
- [ ] Implement turn phase management
- [ ] Connect to CommandQueue for action processing
- [ ] Add win condition (Event integrity <= 0)
- [ ] Add loss condition (Player energy <= 0)
- [ ] Create turn transition animations

---

## 🔧 **Phase B: Integration Tasks**

### 5. CommandQueue Integration
**Current**: Command system exists but not connected
**Needed**: Wire into autoloads and card system

**Tasks**:
- [ ] Add CommandQueue to `project.godot` autoloads:
  ```
  CommandQueue="*res://autoloads/CommandQueue/command_queue.gd"
  ```
- [ ] Create PlayCardCommand class (`autoloads/CommandQueue/play_card_command.gd`)
- [ ] Connect card drag-drop to CommandQueue.add_command()
- [ ] Test command execution with visual feedback

---

### 6. Enhanced EventEntity
**Current**: Basic integrity tracking exists
**Needed**: Visual representation and zone integration

**Tasks**:
- [ ] Inherit from Node2D instead of Node
- [ ] Add `context_type: GameEnums.DaySection` property
- [ ] Add visual HP bar/display
- [ ] Create damage animation system
- [ ] Add death animation and cleanup

---

### 7. Zone Preference System
**Current**: CardStats may have preferred_zone, EventEntity needs context_type
**Needed**: 1.5x bonus calculation in CardPlayedCalculator

**Tasks**:
- [ ] Verify CardStats.preferred_zone property exists
- [ ] Add EventEntity.context_type property
- [ ] Enhance CardPlayedCalculator with zone bonus logic:
  ```gdscript
  func calculate_impact(card: CardStats, event: EventEntity) -> int:
      var base_impact = card.base_impact
      if card.preferred_zone == event.context_type:
          return int(base_impact * 1.5)  # Zone bonus
      return base_impact
  ```

---

### 8. Day Manager → Battle Integration
**Current**: DayManager generates events but no battle resolution
**Needed**: Bridge between event generation and battle system

**Tasks**:
- [ ] Modify DayManager.display_next_event() to load BattleState
- [ ] Create battle scene template (`Main Scenes/battle_encounter.tscn`)
- [ ] Pass EventInstance to BattleState through LevelLoader
- [ ] Handle battle completion → return to DayManager
- [ ] Update event completion tracking

---

## 🎨 **Phase C: Polish & Features**

### 9. Panic Mechanic
**File**: Add to BattleState or HandManager
**Purpose**: Emergency hand refresh at cost

**Tasks**:
- [ ] Add "Panic" button to battle UI
- [ ] Implement hand discard and redraw (5 new cards)
- [ ] Deduct 2 global energy as cost
- [ ] Add visual feedback (stress/panic animation)

---

### 10. Test Content Creation
**Purpose**: Minimal viable content for testing

**Tasks**:
- [ ] Create 5 basic cards with different preferred_zones
- [ ] Create 3 test events (Work/Commute/Home contexts)
- [ ] Set up battle encounter scene with test boss
- [ ] Create simple main menu → game flow

---

## 📋 **Implementation Priority Order**

1. **RunState** (Required by everything else)
2. **CommandQueue Integration** (Add to autoloads)  
3. **HandManager** (Card UI bridge)
4. **BattleState** (Core combat loop)
5. **LevelLoader** (Scene management)
6. **Zone Preference System** (Gameplay depth)
7. **Day Manager Integration** (Connect existing systems)
8. **Test Content** (Validate gameplay)

---

**Estimated Development Time**: 2-3 weeks for Phase A-B, 1 week for Phase C

**Testing Strategy**: After each phase, create minimal test scene to validate integration before moving to next phase.