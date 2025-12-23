This document will explain how the game flows from launch to the game loop finishing one loop to help how to organize classes/nodes/scripts, and what we need to include in each class to be able to pass data around.

The player will launch the game. They will then see options to play the game, from which they will be able to load from 3 save slots. If there is no save slot, then the player will be instantly brought to the main game page. On this page, the player will see buttons such as:
- Edit Deck
- See Achievements
- Start Week
- Buy card packs (Using energy)
There will also be some UI elements, showing the week, how full the players deck is, and so on.
When the player presses start week, the screen will then swap over to the 'week' screen from just the game setup menu, or whatever we want to call the screen that has all of the aforementioned buttons.  The week would start on Monday, the stage of the day would be work. There would be n number of events generated for each section of the day (work, commute, home). The player would then be presented with an event/situation at work. The player's hand would then be populated with 5 cards pulled from the top of their deck (The deck being put into an order, so pulling cards isn't random. Which would allow us to shuffle the deck). The player would then move a card from their hand into the card drop zone to play the card. The excuse card's base damage plus whichever other bonuses would be added to it would be dealt as 'damage' to the event. If the event's health drops below zero, the player would get some success modal about being able to get out of the event. At any point during the event, before the event's health is 0, the player can press the "Attend Event" button on the screen. This will cause the player to take the damage of the event to their energy. If an excuse card has already been played during the event, the player will take the remaining of the of the event's health as energy damage, and they will get 2 embarrassment cards added to their deck for 5 week days (So if they attend event on a Wednesday, the card will be in their deck until next Wednesday, inclusive to that next Wednesday). For basic events (For now we will have basic events and boss fight events) if the player doesn't defeat the event in their first turn using 3 turn energy, then the basic event will either get more health, or get a small modifier. For boss cards (which will only show up on Fridays), they will function a bit differently, but I am not sure how yet. 

After the player fights or attends the events for the work section, then they will go to the commute section (where n number of events will show up), and then the home events. After the home events are finished, the player will be able to regenerate a little bit of energy before starting the next day. This will go on through Friday (There will be a boss event on Friday at the end of one of the three day sections). On the weekend the player will then either choose to rest and get their energy back, or choose to play the weekend which will only have one section which will have special weekend events. If they make it through the events, they will be able to upgrade one of their cards. If they don't, they will start next week with some of their energy missing.



🔄 Major Architecture Updates                                                                                          
                                                                                                                         
  New Components Added:                                                                                                  
                                                                                                                         
  1. DeckManager (Autoload) - Stateless utility for all deck operations (shuffle, draw, discard)                         
  2. EventGenerator - Generates N events per day section based on week/difficulty                                        
  3. HubScene - Main menu with class selection and progress display                                                      
  4. WeekendManager - Rest vs Play choice screen with card upgrade system                                                
  5. SaveSystem - Auto-save after battles, 3 save slots                                                                  
  6. Embarrassment Card Resource - Penalty card for attending events                                                     
                                                                                                                         
  Updated Systems:                                                                                                       
                                                                                                                         
  - RunState - Now merges Player.gd (player_name, player_class, xp, unlocked_cards)                                      
  - HandManager - Uses DeckManager instead of direct deck manipulation                                                   
  - BattleState - Added "Attend Event" surrender button + turn-based event scaling                                       
  - DayManager - Configurable energy regen after Home section                                                            
                                                                                                                         
  Key Architecture Decisions:                                                                                            
                                                                                                                         
  ✅ Data-Behavior Separation (like CardStats + CardPlayedCalculator):                                                   
  - RunState = pure data Resource                                                                                        
  - DeckManager = stateless utility autoload                                                                             
                                                                                                                         
  ✅ Deck Management:                                                                                                    
  - Deck shuffled at day start OR when discard pile is full                                                              
  - Discard pile auto-reshuffles into deck when drawing                                                                  
  - No manual deck editing - cards added via packs/achievements                                                          
                                                                                                                         
  ✅ Weekend System:                                                                                                     
  - Rest = restore full energy (safe)                                                                                    
  - Play = 2 battles for card upgrade (risky, energy penalty on loss)                                                    
                                                                                                                         
  ✅ Embarrassment Cards:                                                                                                
  - Added when attending event AFTER playing cards                                                                       
  - Expire after 5 weekdays (tracked via absolute_day_count)                                                             
                                                                                                                         
  Components to Deprecate:                                                                                               
                                                                                                                         
  - ❌ player.gd → Merged into RunState                                                                                  
  - ❌ deck.gd → Replaced by DeckManager                                                                                 
  - ❌ card_library.gd → Replaced by RunState.unlocked_card_ids                                                          
                                                                                                                         
  Migration Task:                                                                                                        
                                                                                                                         
  - Move Player_Class enum from player.gd to GameEnums.gd (rename to PlayerClass)                                        
                                                                                                                         
  ---                                                                                                                    
  📋 Implementation Priority (5 Sprints)                                                                                 
                                                                                                                         
  Sprint 1: RunState + DeckManager + Embarrassment Card (foundation)                                                     
  Sprint 2: LevelLoader + EventGenerator + Test Content (scene management)                                               
  Sprint 3: HandManager → EventEntity → BattleState (battle systems)                                                     
  Sprint 4: SaveSystem + HubScene + DayManager (meta-game loop)                                                          
  Sprint 5: WeekendManager + optional polish (full game loop)                                                            
                                                                                                                         
  MVP Definition: Player can start new game → select class → complete Mon-Fri battles → make weekend choice → upgrade    
  cards → loop to next week with auto-save.                          