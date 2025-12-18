# Game Development

## Done

- Basic event cycling system (`day_manager.gd`).
- Core logic for event success calculation (`card_played_calculator.gd`).
- Initial setup of Card and Event resources.
- Card state machine for basic card interactions.
- Core architecture for CommandQueue (timekeeper).
- Core architecture for LevelLoader (dependency injection).
- Core architecture for Hierarchical State Machine (game flow).
- Basic EventEntity concept defined.

## To Do

### Phase 1: Foundation (Data & Tools)
- [ ] **Card Resource:** Create `CardStats.gd` inheriting `Resource`.
    - [ ] Add `base_impact` (damage).
    - [ ] Add `preferred_zone` (Enum).
    - [ ] Add `effects` (Array[CardEffect]).
- [ ] **Database Tool:** Create a simple EditorScript (`@tool`) to generate `.tres` files for cards.

### Phase 2: The Battle Engine (Vertical Slice)
- [ ] **Command Queue:** Implement the `command_queue.gd` script.
- [ ] **Hand Manager:**
    - [ ] Logic: Draw 5 cards from `RunState.deck`.
    - [ ] Visual: Instantiate `CardUI` nodes in an `HBoxContainer`.
- [ ] **Event Entity:**
    - [ ] Create a Boss scene (Texture + Label for HP).
    - [ ] Implement `take_impact(amount)` function.

### Phase 3: The Game Loop
- [ ] **State Machine:** Wire up `PlayerTurn` -> `EnemyTurn`.
- [ ] **Win/Loss Conditions:**
    - [ ] If `Event.integrity <= 0`: Transition to `VictoryState` -> Load next Scene.
    - [ ] If `Player.energy <= 0`: Transition to `BurnoutState` (Game Over).

### Phase 4: Content & "Juice"
- [ ] **Create 10 Cards:**
    - [ ] 3 Work Cards ("Fake Report", "Meeting", "Delegation").
    - [ ] 3 Home Cards ("Chores", "Nap", "Mom Called").
    - [ ] 4 General Cards.
- [ ] **Create 1 Event:** "The Boss" (High Integrity, deals Stress every turn).

### General
- **Documentation:**
    - Document the purpose and usage of all major scripts and scenes.
- **UI/UX:**
    - Implement a fully functional deck-building menu.
    - Design and implement the main game screen UI.
    - Create and integrate a main menu.
    - Implement an achievement menu.
- **Gameplay Features:**
    - Implement different card effects.
    - Add more event types and cards.
    - Implement a persistent player profile to save progress and unlocked cards.
- **Art and Assets:**
    - Replace all placeholder assets with final art.
    - Animate card and UI elements.
- **Refinement and Bug Fixing:**
    - Thoroughly test all gameplay mechanics.
    - Refactor and clean up code as needed.
