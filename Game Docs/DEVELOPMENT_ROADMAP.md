# "Excuse Me" Development Roadmap - UPDATED

**Instructions**: As you complete each step, mark it off with `[x]` and write a descriptive commit message following the format:
```
feat: implement card stats resource system
fix: resolve card drag-drop state issues  
refactor: improve command queue error handling
```

**STATUS LEGEND**: ✅ Complete | 🔄 Partially Done | ❌ Not Started

---

## 🏗️ **Milestone 1: Core Foundation Systems - MOSTLY COMPLETE**
*Goal: Complete the fundamental data structures and core systems*

### Epic 1.1: Resource System Implementation ✅ MOSTLY COMPLETE
- [x] **CardStats resource class** (`Resources/Resource Scripts/card_stats.gd`) ✅ EXISTS
  - [x] Basic structure implemented
  - [ ] **VERIFY**: All required properties (base_impact, preferred_zone, effects, cost, category)
- [x] **EventStats resource class** (`Resources/Resource Scripts/event_stats.gd`) ✅ EXISTS
  - [x] Basic structure implemented  
  - [ ] **VERIFY**: All required properties (integrity, context_type, effective_keywords)
- [x] **CardEffect base resource class** (`Resources/Resource Scripts/card_effect.gd`) ✅ EXISTS
  - [x] Base class created
  - [ ] **COMPLETE**: Abstract methods and effect system integration

### Epic 1.2: Core Systems Architecture 🔄 PARTIALLY COMPLETE
- [x] **CommandQueue system** (`autoloads/CommandQueue/command_queue.gd`) ✅ IMPLEMENTED
  - [x] Base Command class exists (`autoloads/CommandQueue/command.gd`)
  - [x] Sequential command processing with await implemented
  - [x] Safety timeout mechanism (5 second fallback)
  - [ ] **ADD**: CommandQueue to project.godot autoloads section
  - [ ] **TEST**: Integration with card play system
- [ ] **Create RunState data persistence** (`Resources/Resource Scripts/run_state.gd`) ❌ MISSING
  - [ ] Add player deck management (Array[CardStats])
  - [ ] Add global energy tracking (player health)
  - [ ] Add day/week progression state
- [ ] **Implement LevelLoader with dependency injection** (`systems/level_loader.gd`) ❌ MISSING
  - [ ] Create scene loading with RunState injection
  - [ ] Implement `inject_state()` pattern for scenes
  - [ ] Add scene transition management

---

## ⚔️ **Milestone 2: Battle System Core - FOUNDATION EXISTS** 
*Goal: Create a functional turn-based card battle system*

### Epic 2.1: Event Entity System ✅ LARGELY COMPLETE
- [x] **EventEntity class** (`game_objects/event/event_entity.gd`) ✅ IMPLEMENTED
  - [x] Basic Node inheritance with integrity tracking
  - [x] `take_impact(amount: int)` method implemented
  - [x] Integrity depletion signal system
  - [ ] **ENHANCE**: Add visual representation (Node2D inheritance)
  - [ ] **ENHANCE**: Add context_type property for zone bonuses
- [x] **EventInstance wrapper** (`game_objects/event/event_instance.gd`) ✅ IMPLEMENTED
  - [x] Combines EventStats with runtime state
  - [x] Event behavior and logic handling
- [ ] **Build test event scene** (`Main Scenes/test_boss_encounter.tscn`) ❌ MISSING
  - [ ] Simple boss with texture and HP label
  - [ ] High integrity for testing (50+ HP)
  - [ ] Basic visual feedback for damage

### Epic 2.2: Hand Management System 🔄 PARTIALLY COMPLETE
- [ ] **Implement HandManager** (`game_objects/hand_manager/hand_manager.gd`) ❌ MISSING
  - [ ] Draw 5 cards from RunState.deck on turn start
  - [ ] Instantiate CardUI nodes in HBoxContainer layout
  - [ ] Handle hand size limits and card positioning
- [x] **Card system foundation** (`game_objects/card/card.gd`) ✅ IMPLEMENTED
  - [x] Card state machine exists (base, clicked, dragging, released states)
  - [x] Card drop area system implemented (`game_objects/card_drop_area/`)
  - [ ] **CONNECT**: To CommandQueue system
  - [ ] **ADD**: Zone preference visual feedback
  - [ ] **ADD**: Card cost validation

### Epic 2.3: Card Effect Processing ✅ EXISTS, NEEDS VERIFICATION
- [x] **CardPlayedCalculator** (`game_objects/card_played_calculator/card_played_calculator.gd`) ✅ IMPLEMENTED
  - [x] Base structure exists
  - [ ] **VERIFY**: Calculate base damage from card stats
  - [ ] **VERIFY**: Apply 1.5x zone preference multiplier
  - [ ] **VERIFY**: Process keyword matching against event vulnerabilities
- [ ] **Implement basic card effects** 🔄 FOUNDATION EXISTS
  - [ ] Direct damage effect
  - [ ] Energy refund effect (for zone preference)
  - [ ] Status effect foundation (for future expansion)

---

## 🎮 **Milestone 3: Complete Game Loop - DAY SYSTEM DONE**
*Goal: Wire together all systems into a playable game experience*

### Epic 3.1: State Machine Implementation 🔄 DAY SYSTEM COMPLETE
- [x] **Existing day progression system** (`game_objects/day_manager/day_manager.gd`) ✅ COMPREHENSIVE
  - [x] Full day/week cycle implemented (Monday-Friday)
  - [x] Day sections (Work/Commute/Home) with context switching
  - [x] Event generation and management per section
  - [x] Background image switching per context
  - [x] Player energy tracking integration
  - [ ] **INTEGRATE**: Connect to battle system
- [ ] **Create BattleState** (`game_objects/battle_state/battle_state.gd`) ❌ MISSING
  - [ ] Implement PlayerTurn → Resolution → EnemyTurn flow
  - [ ] Handle turn energy management (3 energy per turn)
  - [ ] Integrate with CommandQueue for action processing
- [ ] **Build PlayerTurn/EnemyTurn states** ❌ MISSING
  - [ ] Card selection and play validation
  - [ ] Turn energy consumption tracking
  - [ ] Simple AI for enemy actions

### Epic 3.2: Win/Loss Conditions ❌ NEEDS IMPLEMENTATION
- [ ] **Implement victory conditions**
  - [ ] Detect when Event integrity <= 0
  - [ ] Transition to VictoryState scene
  - [ ] Grant rewards and progress to next encounter
- [ ] **Implement defeat conditions**
  - [ ] Detect when player Global Energy <= 0
  - [ ] Transition to BurnoutState (Game Over)
  - [ ] Display defeat screen with restart option
- [ ] **Add Panic mechanic**
  - [ ] "Panic" button during player turn
  - [ ] Discard hand, draw 5 new cards
  - [ ] Cost: -2 Global Energy (permanent damage)

### Epic 3.3: Day/Week Progression ✅ FULLY IMPLEMENTED
- [x] **DayLoopState equivalent** (`game_objects/day_manager/day_manager.gd`) ✅ COMPLETE
  - [x] Work → Commute → Home progression implemented
  - [x] Context-appropriate event spawning with filtering
  - [x] Day completion and progression tracking
  - [x] Background switching per section
- [x] **WeekLoopState equivalent** (integrated in day_manager.gd) ✅ COMPLETE
  - [x] Monday through Friday progression
  - [x] Week completion conditions and reset
  - [x] Weather system and event filtering
  - [x] Player energy tracking integration

---

## 🔧 **PRIORITY TASKS - What To Build Next**

### **Phase A: Connect Existing Systems (HIGH PRIORITY)**
1. [ ] **Add CommandQueue to autoloads** (`project.godot`)
   - Add `CommandQueue="*res://autoloads/CommandQueue/command_queue.gd"`
2. [ ] **Create RunState resource** (`Resources/Resource Scripts/run_state.gd`)
   - Player deck, energy, progression state
3. [ ] **Create HandManager** (`game_objects/hand_manager/hand_manager.gd`)
   - Interface between RunState and Card UI
4. [ ] **Create BattleState** (`game_objects/battle_state/battle_state.gd`)
   - Turn-based combat flow
5. [ ] **Build test encounter scene**
   - Wire day_manager → battle_state → event resolution

### **Phase B: Core Gameplay Loop (MEDIUM PRIORITY)**
1. [ ] **Integrate card play with CommandQueue**
2. [ ] **Implement win/loss conditions**
3. [ ] **Add zone preference bonuses**
4. [ ] **Create basic card effects**

### **Phase C: Content & Polish (LOW PRIORITY)**
- Continue with Milestones 4-5 from original roadmap

---

**Current Assessment**: 
- **Day/Week Management**: ✅ Fully implemented
- **Card/Event Resources**: ✅ Mostly complete  
- **CommandQueue**: ✅ Implemented but not integrated
- **Battle System**: ❌ Missing core components
- **State Management**: ❌ Missing RunState and LevelLoader

**Next Steps**: Focus on Phase A to connect existing systems into a playable battle loop.