# Day Manager Implementation - Three-Part Day System

## Overview
The `day_manager.gd` script has been refactored to implement a three-part day system that sequentially processes Work, Commute, and Home sections. Each section generates its own set of events (1-3 events randomly), and players must go through all events in a section before moving to the next one.

## Architecture

### Key Changes

#### 1. **Removed Single Daily Events Array**
- Removed: `var daily_events: Array[EventInstance]`
- Replaced with three separate arrays for each section:
  - `daily_work_events: Array[EventInstance]`
  - `daily_commute_events: Array[EventInstance]`
  - `daily_home_events: Array[EventInstance]`

#### 2. **Added Current Day Section Tracking**
- New variable: `var current_day_section: GameEnums.DaySection`
- Tracks which section of the day is currently active

#### 3. **New Core Functions**

**`_generate_and_start_day_section(day_section: GameEnums.DaySection)`**
- Orchestrates the start of a new day section
- Sets the current section
- Generates events for that section
- Displays the first event
- Called in sequence: WORK → COMMUTE → HOME

**`_generate_events_for_section(events_array: Array[EventInstance], day_section: GameEnums.DaySection)`**
- Generates 1-3 random events for the given section
- Filters available events based on:
  - Current day of week
  - Current weather
  - Day section requirement
- Uses weighted random selection

**`display_next_event()`**
- Updated to work with the current day section's event array
- Automatically calls `_on_section_completed()` when all events for a section are exhausted

**`_on_section_completed()`**
- Emits the appropriate completion signal based on current section
- Signals: `daily_work_completed`, `daily_commute_completed`, `daily_home_completed`

#### 4. **Section Completion Handlers**

**`_on_work_section_completed()`**
- Triggered after all work events are completed
- Starts the COMMUTE section

**`_on_commute_section_completed()`**
- Triggered after all commute events are completed
- Starts the HOME section

**`_on_home_section_completed()`**
- Triggered after all home events are completed
- Calls `_on_day_completed()` to end the day

#### 5. **Updated Signal Flow**

```
initialize_new_week()
    ↓
_generate_and_start_day_section(WORK)
    ↓ (all work events completed)
daily_work_completed → _on_work_section_completed()
    ↓
_generate_and_start_day_section(COMMUTE)
    ↓ (all commute events completed)
daily_commute_completed → _on_commute_section_completed()
    ↓
_generate_and_start_day_section(HOME)
    ↓ (all home events completed)
daily_home_completed → _on_home_section_completed()
    ↓
_on_day_completed()
    ↓ (if not end of week)
day_completed → _generate_and_start_day_section(WORK) for next day
    ↓ (if end of week)
week_completed → initialize_new_week()
```

## Usage

The system automatically handles the progression:

1. **Week starts**: `initialize_new_week()` is called
2. **Day begins**: First day (Monday) starts with WORK section events
3. **Completing events**: Each time `load_next_event` is emitted (e.g., via Next Event Button), the next event in the section displays
4. **Section complete**: When all events in a section are exhausted, the appropriate completion signal fires
5. **Day progression**: WORK → COMMUTE → HOME → next day's WORK (or week end)
6. **Week ends**: After Friday's HOME section, `week_completed` is emitted and a new week begins

## Integration Notes

- Ensure your EventUI connects to handle `_on_event_completed()` callback when an event finishes
- The `load_next_event` signal should be emitted by your UI (e.g., Next Event Button press)
- The script maintains `current_day` and `current_weather` for proper event filtering
- All event resources are preloaded at startup for performance

## Example Event Flow for Monday

```
Monday starts
→ Work section generated (2 events, for example)
  → Display Event 1 (Player completes)
  → Display Event 2 (Player completes)
  → Work section ends
→ Commute section generated (1 event, for example)
  → Display Event 1 (Player completes)
  → Commute section ends
→ Home section generated (3 events, for example)
  → Display Event 1 (Player completes)
  → Display Event 2 (Player completes)
  → Display Event 3 (Player completes)
  → Home section ends
→ Monday ends, Tuesday begins with Work section
```
