# Missing Systems - Detailed Implementation Breakdown

This document breaks down the unimplemented systems from the roadmap into specific, actionable tasks with implementation details.

**Architecture Update**: This document has been revised to match the confirmed game flow where:
- RunState merges Player.gd (single persistent data source)
- DeckManager handles all deck operations (stateless utility)
- Weekend system includes Rest vs Play choice with card upgrades
- Embarrassment cards have 5-weekday expiration
- Events generated at start of each day, boss events random on Friday
- Auto-save after each battle
- Deck shuffled at start of each day OR when discard pile is full
- No deck editing - cards added via packs/achievements only

**⚠️ Migration Notes**:
- `Player.gd` will be **deprecated** in favor of `RunState` resource
- `Deck.gd` and `Card_Library.gd` nodes will be **replaced** by arrays in RunState
- Move `Player_Class` enum from `player.gd` to `autoloads/GameEnums/game_enums.gd`

---

## 🎯 **Phase A: Core Foundation Systems**

### 1. RunState Resource System (REVISED - Merged with Player)
**File**: `Resources/Resource Scripts/run_state.gd`
**Purpose**: Single source of truth for all persistent game data (replaces Player.gd)

```gdscript
# Implementation Structure Needed:
class_name RunState
extends Resource

# Player Identity
@export var player_name: String = ""
@export var player_class: GameEnums.PlayerClass = GameEnums.PlayerClass.AVOIDER
@export var player_xp: float = 0.0

# Energy System (Dual)
@export var global_energy: int = 50  # Player's health/life pool
@export var max_global_energy: int = 100
@export var turn_energy: int = 3     # Per-turn resource for playing cards
@export var max_turn_energy: int = 3

# Deck System
@export var deck: Array[CardStats] = []              # Draw pile (ordered)
@export var hand: Array[CardStats] = []              # Current hand
@export var discard_pile: Array[CardStats] = []      # Played cards
@export var temporary_cards: Array[Dictionary] = []  # {card: CardStats, added_on_day: int}

# Progression Tracking
@export var current_week: int = 1
@export var current_day: GameEnums.WeekDay = GameEnums.WeekDay.MONDAY
@export var current_day_section: GameEnums.DaySection = GameEnums.DaySection.WORK
@export var absolute_day_count: int = 1  # Total days elapsed (for embarrassment card expiration)

# Unlocks & Achievements
@export var unlocked_card_ids: Array[String] = []  # Card IDs available in packs (Card Library)
@export var completed_achievements: Array[String] = []

# Event Tracking (Daily)
@export var completed_events_today: Array[String] = []

# Settings
@export var home_section_energy_regen: int = 5  # Configurable energy regen after Home section
```

**Implementation Tasks**:
- [ ] Create `Resources/Resource Scripts/run_state.gd` file
- [ ] Add `class_name RunState` declaration
- [ ] Extend `Resource` class for save/load support
- [ ] Add all player identity properties (name, class, xp)
- [ ] Add dual energy system properties (global and turn energy)
- [ ] Add deck system arrays (deck, hand, discard_pile, temporary_cards)
- [ ] Add progression tracking properties (week, day, day_section, absolute_day_count)
- [ ] Add unlocks arrays (unlocked_card_ids, completed_achievements)
- [ ] Add daily event tracking (completed_events_today)
- [ ] Add configurable settings (home_section_energy_regen)
- [ ] Add helper method: `get_total_deck_size() -> int` (deck + hand + discard)
- [ ] Add helper method: `has_card_unlocked(card_id: String) -> bool`
- [ ] Add helper method: `is_new_game() -> bool` (checks if player_name is empty)

**Testing Tasks**:
- [ ] Create test RunState resource
- [ ] Test: Verify all properties serialize/deserialize correctly
- [ ] Test: Set player_name, verify is_new_game() returns false
- [ ] Test: Add cards to deck/hand/discard, verify get_total_deck_size() is correct
- [ ] Test: Add temporary card with expiration, verify structure is valid
- [ ] Test: Call duplicate(true), verify deep copy works

---

### 2. DeckManager System (NEW - Stateless Utility)
**File**: `autoloads/DeckManager/deck_manager.gd`
**Purpose**: Stateless utility for all deck operations (replaces Deck.gd node pattern)

```gdscript
# Implementation Structure Needed:
class_name DeckManager
extends Node  # Autoload singleton

# Core deck operations
static func shuffle_deck(state: RunState) -> void
static func draw_card(state: RunState) -> CardStats  # Returns null if deck empty
static func discard_card(state: RunState, card: CardStats) -> void
static func reshuffle_discard_into_deck(state: RunState) -> void

# Temporary card management (Embarrassment cards)
static func add_temporary_card(state: RunState, card: CardStats, added_on_day: int) -> void
static func remove_expired_temporary_cards(state: RunState) -> void

# Class-based deck generation
static func generate_starter_deck(player_class: GameEnums.PlayerClass) -> Array[CardStats]
```

**Implementation Tasks**:
- [ ] Create `autoloads/DeckManager/` directory
- [ ] Create `autoloads/DeckManager/deck_manager.gd` file
- [ ] Add `class_name DeckManager` and `extends Node`
- [ ] Add to autoload in `project.godot`: `DeckManager="*res://autoloads/DeckManager/deck_manager.gd"`
- [ ] Implement `shuffle_deck(state: RunState)` using `state.deck.shuffle()`
- [ ] Implement `draw_card(state: RunState) -> CardStats`:
  - Check if deck is empty, if so call `reshuffle_discard_into_deck()`
  - If still empty, return null
  - Remove first card from deck, add to hand, return card
- [ ] Implement `discard_card(state: RunState, card: CardStats)`:
  - Remove from hand array
  - Add to discard_pile array
- [ ] Implement `reshuffle_discard_into_deck(state: RunState)`:
  - Append all discard_pile cards to deck
  - Clear discard_pile
  - Call shuffle_deck()
- [ ] Implement `add_temporary_card(state: RunState, card: CardStats, added_on_day: int)`:
  - Add dictionary `{card: card, added_on_day: added_on_day}` to temporary_cards
  - Add card to deck
  - Call shuffle_deck()
- [ ] Implement `remove_expired_temporary_cards(state: RunState)`:
  - Loop through temporary_cards
  - If `state.absolute_day_count - entry.added_on_day >= 5`, remove card from deck
  - Remove expired entries from temporary_cards array
- [ ] Implement `generate_starter_deck(player_class: GameEnums.PlayerClass) -> Array[CardStats]`:
  - Load predefined starter cards based on class
  - Return array of 15-20 starter cards
- [ ] Add helper: `get_deck_card_count(state: RunState) -> int` (deck + discard_pile size)

**Testing Tasks**:
- [ ] Create test scene with test RunState
- [ ] Test: Add 10 cards to deck, call shuffle_deck(), verify order changes
- [ ] Test: Draw 5 cards, verify deck decreases by 5, hand increases by 5
- [ ] Test: Draw until deck empty, verify discard pile auto-reshuffles into deck
- [ ] Test: Discard 3 cards, verify they move from hand to discard_pile
- [ ] Test: Add temporary card with day 1, set absolute_day_count to 6, call remove_expired, verify card removed
- [ ] Test: Generate starter deck for each player class, verify cards are different
- [ ] Test: Draw card when deck AND discard are empty, verify returns null gracefully

---

### 3. LevelLoader with Dependency Injection
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

### 4. EventGenerator System (NEW)
**File**: `systems/event_generator.gd`
**Purpose**: Generates events at start of each day based on week/difficulty

```gdscript
# Implementation Structure Needed:
class_name EventGenerator
extends Node

# Event pools for each context
@export var work_event_pool: Array[EventStats] = []
@export var commute_event_pool: Array[EventStats] = []
@export var home_event_pool: Array[EventStats] = []
@export var boss_event_pool: Array[EventStats] = []
@export var weekend_event_pool: Array[EventStats] = []

func generate_day_events(week: int, day: GameEnums.WeekDay) -> Dictionary
func inject_boss_event_if_friday(events: Dictionary, day: GameEnums.WeekDay) -> void
func generate_weekend_events(week: int) -> Array[EventStats]
```

**Implementation Tasks**:
- [ ] Create `systems/event_generator.gd` file
- [ ] Add `class_name EventGenerator` and `extends Node`
- [ ] Add @export arrays for event pools (work, commute, home, boss, weekend)
- [ ] Implement `get_event_count_for_week(week: int) -> int`:
  - Week 1: 2-3 events per section
  - Week 2: 3-4 events per section
  - Week 3+: 4-5 events per section
- [ ] Implement `generate_day_events(week: int, day: GameEnums.WeekDay) -> Dictionary`:
  - Returns `{work: Array[EventStats], commute: Array[EventStats], home: Array[EventStats]}`
  - Call `inject_boss_event_if_friday()` before returning
- [ ] Implement `pick_random_events_from_pool(pool: Array[EventStats], count: int) -> Array[EventStats]`
- [ ] Implement `inject_boss_event_if_friday(events: Dictionary, day: GameEnums.WeekDay)`:
  - If day is FRIDAY, pick random section ("work", "commute", or "home")
  - Append random boss event to that section's array
- [ ] Implement `generate_weekend_events(week: int) -> Array[EventStats]`:
  - Always returns 2 events from weekend_event_pool
- [ ] Add helper: `scale_event_difficulty(event: EventStats, week: int) -> EventStats`:
  - Multiply integrity by week multiplier (1.0, 1.2, 1.5, etc.)

**Testing Tasks**:
- [ ] Create test EventGenerator with populated event pools
- [ ] Test: Generate week 1 events, verify 2-3 events per section
- [ ] Test: Generate week 3 events, verify 4-5 events per section
- [ ] Test: Generate Friday events, verify boss event appears in random section
- [ ] Test: Generate weekend events, verify always returns 2 events
- [ ] Test: Call scale_event_difficulty with week 3, verify integrity is scaled

---

### 5. HandManager System
**File**: `game_objects/hand_manager/hand_manager.gd`
**Purpose**: Bridge between RunState and Card UI system (UPDATED - uses DeckManager)

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
- [ ] Implement `draw_starting_hand() -> void` (draws STARTING_HAND_SIZE cards using DeckManager)
- [ ] Implement `draw_cards(count: int) -> void` (loops and calls DeckManager.draw_card())
- [ ] Implement `draw_single_card() -> void`:
  - Call `DeckManager.draw_card(run_state)`
  - Create CardUI for drawn card
  - Add to hand_container
- [ ] Implement `create_card_ui(card: CardStats) -> CardUI` (instantiate scene, set card data)
- [ ] Implement `add_card_to_hand_ui(card: CardStats) -> void` (creates UI, adds to container)
- [ ] Implement `remove_card_from_hand_ui(card_ui: CardUI) -> void` (removes from container, queue_free)
- [ ] Implement `play_card(card: CardStats, target: EventEntity) -> void`:
  - Call `DeckManager.discard_card(run_state, card)`
  - Create PlayCardCommand
  - Add to CommandQueue
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

### 6. BattleState System (UPDATED - Attend Event + Turn Scaling)
**File**: `game_objects/battle_state/battle_state.gd`
**Purpose**: Turn-based combat state machine with surrender option

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
- [ ] **NEW: Implement "Attend Event" system**:
  - Add signal: `signal event_attended`
  - Add property: `var has_played_card_this_battle: bool = false`
  - Implement `attend_event() -> void`:
    - Take remaining event integrity as damage to global_energy
    - If has_played_card_this_battle == true, add 2 embarrassment cards
    - Call `DeckManager.add_temporary_card()` twice with current absolute_day_count
    - Call `DeckManager.shuffle_deck(run_state)`
    - Emit event_attended signal
  - Set has_played_card_this_battle = true when card is played
- [ ] **NEW: Implement turn-based event scaling** (basic events only):
  - Add property to EventEntity: `var is_boss_event: bool = false`
  - At end of turn 1 (if event not defeated and not boss):
    - Randomly choose: add +5 integrity OR add damage modifier
    - If modifier chosen, increase event's damage by 20%
- [ ] Create `game_objects/battle_state/battle_state.tscn` scene with UI elements
- [ ] Add Label for phase display (e.g., "Player Turn", "Enemy Turn")
- [ ] Add Label for turn counter display
- [ ] Add Button: "Attend Event" that calls attend_event()
- [ ] Update "Attend Event" button tooltip to show: damage taken + embarrassment penalty if card played
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

### 10. HubScene (NEW - Main Menu / Game Setup)
**File**: `Main Scenes/hub_scene.tscn` + `Main Scenes/hub_scene.gd`
**Purpose**: Central menu where player manages deck, views progress, and starts weeks

```gdscript
# Implementation Structure Needed:
class_name HubScene
extends Control

@onready var week_label: Label
@onready var energy_label: Label
@onready var deck_size_label: Label
@onready var class_selection_panel: Panel  # Only shown for new games

var run_state: RunState

func inject_state(state: RunState) -> void
func show_class_selection() -> void  # For new games
func initialize_new_game(player_class: GameEnums.PlayerClass) -> void
```

**Implementation Tasks**:
- [ ] Create `Main Scenes/hub_scene.tscn` scene
- [ ] Add UI elements: week label, energy label, deck size label
- [ ] Add buttons: "Start Week", "View Card Pool", "Buy Packs" (if implemented)
- [ ] Create `Main Scenes/hub_scene.gd` script
- [ ] Add `class_name HubScene` and extend `Control`
- [ ] Implement `inject_state(state: RunState) -> void`:
  - Check if `state.is_new_game()`, if true call `show_class_selection()`
  - Update all UI labels with state data
- [ ] Implement `show_class_selection() -> void`:
  - Show panel with 5 class buttons (AVOIDER, OVERSHARER, APOLOGIZER, DOOMSCROLLER, FLAKE)
  - Each button calls `on_class_selected(class)`
- [ ] Implement `on_class_selected(player_class: GameEnums.PlayerClass) -> void`:
  - Set `run_state.player_class = player_class`
  - Generate starter deck: `run_state.deck = DeckManager.generate_starter_deck(player_class)`
  - Shuffle deck: `DeckManager.shuffle_deck(run_state)`
  - Prompt for player name (LineEdit popup)
  - Hide class selection panel
- [ ] Implement `_on_start_week_pressed() -> void`:
  - Call `LevelLoader.transition_to_scene("res://Main Scenes/week_view.tscn")`
- [ ] Implement `_on_view_card_pool_pressed() -> void`:
  - Show modal with all unlocked card IDs (read-only view)
- [ ] Connect button signals to respective methods
- [ ] Add visual polish: class descriptions, card pool grid layout

**Testing Tasks**:
- [ ] Test: Load HubScene with new RunState (is_new_game() == true), verify class selection shows
- [ ] Test: Select AVOIDER class, verify starter deck is generated
- [ ] Test: Enter player name, verify run_state.player_name is set
- [ ] Test: Load HubScene with existing RunState, verify class selection is hidden
- [ ] Test: Click "Start Week", verify transition to week view
- [ ] Test: Click "View Card Pool", verify modal shows unlocked cards

---

### 11. WeekendManager (NEW)
**File**: `Main Scenes/weekend_manager.tscn` + `Main Scenes/weekend_manager.gd`
**Purpose**: Weekend choice screen (Rest or Play) with card upgrade on victory

```gdscript
# Implementation Structure Needed:
class_name WeekendManager
extends Control

signal weekend_rest_chosen
signal weekend_play_chosen
signal weekend_completed(success: bool)

var run_state: RunState
var weekend_events: Array[EventStats] = []
var current_event_index: int = 0

func inject_state(state: RunState) -> void
func show_weekend_choice() -> void
func start_weekend_battles() -> void
func on_battle_won() -> void
func on_battle_lost() -> void
func show_upgrade_ui() -> void
```

**Implementation Tasks**:
- [ ] Create `Main Scenes/weekend_manager.tscn` scene
- [ ] Add UI: "Rest" button, "Play Weekend" button
- [ ] Create `Main Scenes/weekend_manager.gd` script
- [ ] Add signals: weekend_rest_chosen, weekend_play_chosen, weekend_completed
- [ ] Implement `inject_state(state: RunState) -> void`
- [ ] Implement `show_weekend_choice() -> void`:
  - Display "Rest" button (tooltip: "Restore energy to full")
  - Display "Play Weekend" button (tooltip: "Battle 2 events, upgrade a card on victory")
- [ ] Implement `_on_rest_pressed() -> void`:
  - Set `run_state.global_energy = run_state.max_global_energy`
  - Emit weekend_rest_chosen signal
  - Transition to HubScene
- [ ] Implement `_on_play_weekend_pressed() -> void`:
  - Generate 2 weekend events using EventGenerator
  - Transition to first battle
- [ ] Implement `on_battle_won() -> void`:
  - Increment current_event_index
  - If current_event_index < 2, load next battle
  - Else: call show_upgrade_ui()
- [ ] Implement `on_battle_lost() -> void`:
  - Apply energy penalty (e.g., -20 global_energy)
  - Emit weekend_completed(false)
  - Transition to HubScene
- [ ] Implement `show_upgrade_ui() -> void`:
  - Pick 5 random cards from run_state.deck
  - Show upgrade options: +2 damage, -1 cost, or add keyword
  - Apply upgrade to selected card
  - Transition to HubScene
- [ ] Connect to BattleState.battle_won and battle_lost signals

**Testing Tasks**:
- [ ] Test: Click "Rest", verify energy restored to max
- [ ] Test: Click "Play Weekend", verify 2 events are generated
- [ ] Test: Win first weekend battle, verify second battle loads
- [ ] Test: Win both battles, verify upgrade UI shows 5 cards
- [ ] Test: Lose weekend battle, verify energy penalty applied
- [ ] Test: Upgrade a card, verify changes persist in run_state.deck

---

### 12. SaveSystem (Enhancement to GameManager)
**File**: `autoloads/GameManager/game_manager.gd`
**Purpose**: Auto-save after each battle, 3 save slots

**Implementation Tasks**:
- [ ] Open existing `autoloads/GameManager/game_manager.gd` (if exists, else create)
- [ ] Add property: `var current_save_slot: int = 0` (1, 2, or 3)
- [ ] Add constant: `const SAVE_DIR: String = "user://saves/"`
- [ ] Implement `save_run_state(slot: int, state: RunState) -> void`:
  - Create save directory if not exists
  - Serialize RunState to JSON or binary
  - Write to `user://saves/slot_X.sav`
  - Store timestamp metadata
- [ ] Implement `load_run_state(slot: int) -> RunState`:
  - Read from save file
  - Deserialize to RunState resource
  - Return RunState or null if slot empty
- [ ] Implement `auto_save_after_battle() -> void`:
  - Call save_run_state(current_save_slot, LevelLoader.run_state)
- [ ] Implement `has_save_in_slot(slot: int) -> bool`
- [ ] Implement `get_save_slot_info(slot: int) -> Dictionary`:
  - Returns {player_name, week, day, timestamp} for slot preview
- [ ] Connect to BattleState.battle_won and battle_lost signals for auto-save trigger
- [ ] Add save slot selection UI in main menu (before HubScene)

**Testing Tasks**:
- [ ] Test: Save RunState to slot 1, verify file created in user://saves/
- [ ] Test: Load from slot 1, verify RunState matches saved data
- [ ] Test: Complete battle, verify auto-save triggers
- [ ] Test: Save to all 3 slots, verify each slot is independent
- [ ] Test: Check has_save_in_slot() for empty slot, verify returns false
- [ ] Test: Get save slot info, verify correct metadata returned

---

### 13. Embarrassment Card Resource (NEW)
**File**: `Resources/Card Types/System Cards/embarrassment_card.tres`
**Purpose**: Penalty card added when attending events after playing cards

**Implementation Tasks**:
- [ ] Create `Resources/Card Types/System Cards/` directory
- [ ] Create `embarrassment_card.tres` CardStats resource
- [ ] Set properties:
  - card_name: "Embarrassment"
  - card_cost: 1
  - base_impact: 0 (does nothing helpful)
  - card_flavor_text: "The awkward memory of giving up haunts you."
  - preferred_zone: null (no bonus)
- [ ] Add negative effect (optional): "At end of turn, take 1 damage" or similar
- [ ] Create visual asset for embarrassment card (placeholder art acceptable)
- [ ] Verify card loads correctly when called by DeckManager.add_temporary_card()

**Testing Tasks**:
- [ ] Test: Load embarrassment_card.tres, verify all properties are set
- [ ] Test: Add to deck, verify it appears in hand when drawn
- [ ] Test: Play embarrassment card, verify it costs 1 turn_energy and does nothing
- [ ] Test: Verify visual asset displays correctly in CardUI

---

### 14. Card Pack System (NEW - Optional for MVP)
**File**: `systems/card_pack_manager.gd`
**Purpose**: Spend energy to open packs with random unlocked cards

**Implementation Tasks**:
- [ ] Create `systems/card_pack_manager.gd` file
- [ ] Add `class_name CardPackManager` and extend Node
- [ ] Add constant: `const PACK_COST: int = 10` (energy cost per pack)
- [ ] Add constant: `const CARDS_PER_PACK: int = 3`
- [ ] Implement `can_afford_pack(state: RunState) -> bool`
- [ ] Implement `open_pack(state: RunState) -> Array[CardStats]`:
  - Check if state.global_energy >= PACK_COST
  - Deduct energy
  - Pick 3 random card IDs from state.unlocked_card_ids
  - Load CardStats resources and add to state.deck
  - Return array of new cards for display
- [ ] Create UI in HubScene for "Buy Packs" button
- [ ] Show pack opening animation with revealed cards
- [ ] Add cards directly to deck after opening

**Testing Tasks**:
- [ ] Test: Unlock 10 cards, open pack, verify 3 random cards added to deck
- [ ] Test: Open pack with energy = 9, verify pack opening fails
- [ ] Test: Open pack with energy = 10, verify energy drops to 0
- [ ] Test: Open pack, verify cards are from unlocked pool only

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

## 📋 **Implementation Priority Order (REVISED)**

### Recommended Implementation Sequence:

**Sprint 1: Core Data & Utilities (Foundation Layer)**
1. **RunState** (Merged with Player.gd)
   - Single source of truth for all persistent data
   - Complete all Implementation Tasks
   - Complete all Testing Tasks

2. **DeckManager** (Stateless utility autoload)
   - Required for all deck operations
   - Complete all Implementation Tasks
   - Complete all Testing Tasks
   - Verify shuffle, draw, discard work correctly

3. **Embarrassment Card Resource**
   - Create penalty card resource
   - Quick win, needed for Attend Event feature

**Sprint 2: Scene Management & Content Generation**
4. **LevelLoader** (State injection system)
   - Scene transitions with RunState persistence
   - Complete all Implementation Tasks
   - Complete all Testing Tasks

5. **EventGenerator** (Event pool and generation)
   - Generates events for each day/section
   - Complete all Implementation Tasks
   - Complete all Testing Tasks

6. **Test Content Creation**
   - Create 5-10 test cards for each zone
   - Create 10-15 test events (work, commute, home)
   - Create 2-3 boss events
   - Create 2-3 weekend events
   - Ensures system can be tested with real content

**Sprint 3: Battle Systems (Core Gameplay Loop)**
7. **HandManager** (Updated to use DeckManager)
   - Card UI and hand management
   - Complete all Implementation Tasks
   - Complete all Testing Tasks

8. **Enhanced EventEntity** (Visual representation)
   - Damage animations, health bars
   - Complete all Implementation Tasks
   - Complete all Testing Tasks

9. **Zone Preference System**
   - 1.5x damage bonus for preferred zones
   - Complete all Implementation Tasks
   - Complete all Testing Tasks

10. **CommandQueue Integration**
    - Wire into card play system
    - Complete all Implementation Tasks
    - Complete all Testing Tasks

11. **BattleState** (UPDATED with Attend Event + Turn Scaling)
    - Core turn-based combat loop
    - Attend Event surrender button
    - Turn-based event scaling
    - Complete all Implementation Tasks
    - Complete all Testing Tasks
    - **Milestone**: Can complete a full battle from start to victory/defeat

**Sprint 4: Meta-Game Systems (Week Loop)**
12. **SaveSystem** (Auto-save + 3 slots)
    - Save/load RunState
    - Auto-save after each battle
    - Complete all Implementation Tasks
    - Complete all Testing Tasks

13. **HubScene** (Main menu / game setup)
    - Class selection for new games
    - View progress and start weeks
    - Complete all Implementation Tasks
    - Complete all Testing Tasks

14. **Day Manager Integration** (Updated for energy regen)
    - Connect day sections to battles
    - Energy regen after Home section
    - Day progression and event flow
    - Complete all Implementation Tasks
    - Complete all Testing Tasks
    - **Milestone**: Full weekday loop (Mon-Fri) works

15. **WeekendManager** (Rest vs Play)
    - Weekend choice screen
    - Card upgrade system
    - Complete all Implementation Tasks
    - Complete all Testing Tasks
    - **Milestone**: Full week loop (Mon-Sat/Sun) works

**Sprint 5: Polish & Optional Features**
16. **Card Pack System** (Optional)
    - Spend energy to get new cards
    - Nice-to-have, not critical for MVP

17. **Panic Mechanic** (Polish)
    - Emergency hand refresh
    - Complete all Implementation Tasks
    - Complete all Testing Tasks

---

### Critical Path to MVP:
1. ✅ RunState + DeckManager (data foundation)
2. ✅ LevelLoader + EventGenerator (scene management)
3. ✅ Battle systems (HandManager → EventEntity → BattleState)
4. ✅ SaveSystem + HubScene (meta-game loop)
5. ✅ Day progression + Weekend system (full game loop)

**Definition of MVP**: Player can start new game, select class, complete weekday battles (Mon-Fri), make weekend choice, upgrade cards, and loop back to next week with persistent saves.

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
- [ ] Can start new game, select class, and receive starter deck
- [ ] Can complete full weekday battle sequence (Mon-Fri)
- [ ] Can make weekend choice (Rest or Play)
- [ ] Weekend victories grant card upgrades
- [ ] RunState persists across all scene transitions
- [ ] Auto-save triggers after each battle
- [ ] Zone bonus system works (1.5x damage)
- [ ] Attend Event button works with embarrassment card penalty
- [ ] Embarrassment cards expire after 5 weekdays
- [ ] Full game loop: Hub → Week → Battles → Weekend → Hub (repeat)

---

## 📐 **Architecture Summary**

### New Component Hierarchy:

```
RunState (Resource - Pure Data)
  ↓ operated on by ↓
DeckManager (Autoload - Stateless Utility)
  ↓ used by ↓
HandManager (Scene Node - UI Manager)
  ↓ feeds into ↓
BattleState (Scene Node - Combat Controller)
  ↓ triggered by ↓
DayManager (State Machine - Day Orchestrator)
  ↓ coordinated by ↓
LevelLoader (Injection System - Scene Manager)
```

### Key Design Decisions:

1. **Data-Behavior Separation**
   - ✅ RunState = pure data (Resource)
   - ✅ DeckManager = pure behavior (static utility)
   - ✅ Matches CardStats + CardPlayedCalculator pattern

2. **No Global Mutable State**
   - ✅ RunState passed via dependency injection
   - ✅ LevelLoader handles state transport between scenes
   - ❌ No autoload singletons for game state

3. **Deck as Ordered Array**
   - ✅ Deck is Array[CardStats] in specific order
   - ✅ Shuffled at day start + when discard pile full
   - ✅ Discard pile auto-reshuffles into deck when empty

4. **Weekend as Strategic Choice**
   - ✅ Rest = full energy restore (safe)
   - ✅ Play = 2 battles for card upgrade (risky)
   - ✅ Loss penalty = reduced energy next week

5. **Embarrassment as Temporary Deck Pollution**
   - ✅ Added when attending event after playing cards
   - ✅ Auto-removed after 5 weekdays (via absolute_day_count)
   - ✅ Forces deck management decisions

### Deprecated Components:
- ❌ `game_objects/player/player.gd` → Merged into RunState
- ❌ `game_objects/deck/deck.gd` → Replaced by DeckManager
- ❌ `game_objects/card_library/card_library.gd` → Replaced by RunState.unlocked_card_ids

---

## 🚀 **Quick Start Guide**

To begin implementation:

1. **Start with Sprint 1**: RunState + DeckManager + Embarrassment Card
2. **Test thoroughly**: Each system must pass all tests before moving on
3. **Follow the critical path**: Foundation → Scene Management → Battle → Meta-Game
4. **Use the existing patterns**: Mimic CardPlayedCalculator for stateless utilities
5. **Refer to Game Flow Plan**: Always validate against intended player experience

When in doubt, ask: "Does this match the RunState/DeckManager pattern?"