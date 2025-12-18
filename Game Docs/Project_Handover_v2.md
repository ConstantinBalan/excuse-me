Project Handover: "Excuse Me"Version: 2.0 (Gameplay Logic Defined)Engine: Godot 4.x (GDScript)Team: Dragos (Lead/Arch), Dani (Dev)1. Core Gameplay Loop (The "Rules of Reality")A. The Deck & ZonesUnified Deck: The player maintains one single deck used for all encounters.Contextual Synergy: Cards have a preferred_zone (Work, Commute, Home).Mechanic: Playing a card in its preferred zone grants a Crit (Double Impact) or Refund (Energy back).Narrative: Lying about "Traffic" works better during a Commute than it does at Home.B. The Encounter Structure (Turn-Based)Encounters are Multi-Turn Battles.The Player: Starts turn with 5 Cards and 3 Turn-Energy (refills each turn).The Event (Enemy): Has Integrity (HP) and Intent (Next Move).Winning: Reduce Event Integrity to 0.Losing: Player Global Energy (Health) hits 0 -> Burnout.C. The "Panic" MechanicAction: The player can click "Panic" at any time during their turn.Effect: Discard current hand, draw 5 new cards.Cost: -2 Global Energy (Permanent health damage for the day).Why: Represents the stress of spiraling when caught in a lie.2. Technical Architecture SpecificationA. The "Entity" Abstraction (How to code non-combat enemies)Confusion Point: How do we "attack" a Traffic Jam?Solution: We abstract "Combat" into "Resolution".Class: EventEntity (Inherits Node2D/Control)Variable: integrity (int). Acts as HP.Variable: context_type (Enum: WORK, COMMUTE, HOME).Logic: When a Card is played, it checks EventEntity.context_type. If it matches the card's type, apply 1.5x multiplier.B. The CommandQueue (The Timekeeper)Pattern: Command Pattern with await.Goal: Decouple logic calculation from visual execution. prevents "card happens before animation finishes."File: systems/command_queue/command_queue.gdGDScriptclass_name CommandQueue extends Node

var _queue: Array[Command] =
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
C. The LevelLoader (Dependency Injection)Pattern: Resource Injection.Goal: Persist RunState (Deck, Health, Day) across scenes without fragile Singletons.File: systems/level_loader.gdGDScriptfunc load_encounter(scene_path: String, run_state: RunState) -> void:
    # 1. Load Scene in Memory
    var next_scene = load(scene_path).instantiate()
    
    # 2. INJECT DATA (Crucial Step)
    if next_scene.has_method("inject_state"):
        next_scene.inject_state(run_state)
    
    # 3. Switch Scene Tree
    _current_scene.queue_free()
    get_tree().root.add_child(next_scene)
    _current_scene = next_scene
D. Hierarchical State Machine (The Brain)Structure:GameLoopWeekState (Tracks Mon-Fri)DayState (Tracks Morning/Commute/Work/Home)BattleState (The actual card game)PlayerTurnResolution (Waits for Queue)EnemyTurn3. Implementation Checklist (TODO)Phase 1: Foundation (Data & Tools)[ ] CardResource: Create CardStats.gd inheriting Resource.[ ] Add base_impact (damage).[ ] Add preferred_zone (Enum).[ ] Add effects (Array[CardEffect]).[ ] Database Tool: Create a simple EditorScript (@tool) to generate .tres files for cards so we don't have to make them manually.Phase 2: The Battle Engine (Vertical Slice)[ ] Command Queue: Implement the script above.[ ] Hand Manager:[ ] Logic: Draw 5 cards from RunState.deck.[ ] Visual: Instantiate CardUI nodes in an HBoxContainer.[ ] Event Entity:[ ] Create a Boss scene (Texture + Label for HP).[ ] Implement take_impact(amount) function.Phase 3: The Game Loop[ ] State Machine: Wire up PlayerTurn -> EnemyTurn.[ ] Win/Loss:[ ] If Event.integrity <= 0: Transition to VictoryState -> Load next Scene.[ ] If Player.energy <= 0: Transition to BurnoutState (Game Over).Phase 4: Content & "Juice"[ ] Create 10 Cards:[ ] 3 Work Cards ("Fake Report", "Meeting", "Delegation").[ ] 3 Home Cards ("Chores", "Nap", "Mom Called").[ ] 4 General Cards.[ ] Create 1 Event: "The Boss" (High Integrity, deals Stress every turn).4. Instructions for AI Assistant (Gemini)Role: You are acting as Dragos (Senior Architect).Strict Rule: Do not provide monologues. Provide Code Snippets and Architectural Diagrams.Context: The user (Lead) needs to see how the RunState passes data to the BattleScene. Focus on Dependency Injection.