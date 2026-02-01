# T12: Memory System — Tests

## Test Environment

```
test-vault-populated/          ← With 9_Meta/memory.md and state.json
```

**Mocks:**
- System clock
- User context

---

## Test Suite: Memory File Structure

### T12.1: Memory file exists after scaffold
**Code type:** Bash script

```pseudo
GIVEN scaffold_vault() executed
THEN 9_Meta/memory.md exists
AND file has valid frontmatter
```

### T12.2: Memory file frontmatter structure
**Code type:** Python script

```pseudo
GIVEN 9_Meta/memory.md
THEN frontmatter contains:
  - type: memory
  - created: <timestamp>
  - updated: <timestamp>
```

### T12.3: Memory sections structure
**Code type:** Python script

```pseudo
GIVEN 9_Meta/memory.md
THEN body contains sections:
  - ## Preferences
  - ## Context
  - ## Patterns
  - ## Recent Focus
```

---

## Test Suite: Preference Storage

### T12.4: Store user preference
**Code type:** Python script

```pseudo
GIVEN user says: "Remember that I prefer morning meetings"
WHEN store_preference("meeting_time", "morning preferred")
THEN memory.md ## Preferences section contains:
  "- **Meeting time:** morning preferred"
```

### T12.5: Retrieve preference
**Code type:** Python script

```pseudo
GIVEN preference stored: meeting_time = "morning preferred"
WHEN get_preference("meeting_time")
THEN returns "morning preferred"
```

### T12.6: Update existing preference
**Code type:** Python script

```pseudo
GIVEN preference: meeting_time = "morning preferred"
WHEN store_preference("meeting_time", "afternoon preferred")
THEN preference updated (not duplicated)
AND updated timestamp refreshed
```

### T12.7: List all preferences
**Code type:** Python script

```pseudo
GIVEN 3 preferences stored
WHEN list_preferences()
THEN returns all 3 preference entries
```

---

## Test Suite: Context Persistence

### T12.8: Store working context
**Code type:** Python script

```pseudo
GIVEN user working on domain pricing
WHEN store_context("current_focus", "Domain pricing for Q1 launch")
THEN memory.md ## Context section updated
```

### T12.9: Context available across sessions
**Code type:** Prompt/Response

```pseudo
GIVEN context stored: "Working on domain bundling project"
WHEN new Claude session starts
THEN Claude has access to stored context
```

### T12.10: Auto-update context from activity
**Code type:** Python script

```pseudo
GIVEN config.memory.auto_context = true
AND user frequently accesses domain-bundling project
WHEN analyzing activity patterns
THEN context updated: "Recent focus: domain-bundling project"
```

---

## Test Suite: Pattern Learning

### T12.11: Detect work patterns
**Code type:** Python script

```pseudo
GIVEN morning briefs consistently at 08:00-08:30
WHEN analyze_patterns()
THEN patterns section includes:
  "- **Brief time:** typically 08:00-08:30"
```

### T12.12: Detect project patterns
**Code type:** Python script

```pseudo
GIVEN user consistently files pricing notes to domain-bundling
WHEN analyze_patterns()
THEN patterns section includes:
  "- Pricing content → domain-bundling project"
```

### T12.13: Use patterns for suggestions
**Code type:** Prompt/Response

```pseudo
GIVEN pattern: "Pricing content → domain-bundling"
AND new capture about pricing
WHEN suggesting destination
THEN domain-bundling is top suggestion with rationale:
  "Based on your pattern of filing pricing content here"
```

---

## Test Suite: Recent Focus Tracking

### T12.14: Track recently accessed files
**Code type:** Python script

```pseudo
GIVEN user accessed domain-bundling.md, jane-smith.md, pricing-analysis.md
WHEN update_recent_focus()
THEN ## Recent Focus section shows recent files
```

### T12.15: Track recent projects
**Code type:** Python script

```pseudo
GIVEN user worked on domain-bundling and bi-phase-1 this week
WHEN get_recent_projects()
THEN returns [domain-bundling, bi-phase-1] in recency order
```

### T12.16: Limit recent focus list
**Code type:** Python script

```pseudo
GIVEN config.memory.recent_limit = 10
AND 15 items in recent focus
WHEN trimming recent focus
THEN only most recent 10 kept
```

---

## Test Suite: State Management

### T12.17: State file structure
**Code type:** Python script

```pseudo
GIVEN 9_Meta/state.json
THEN contains:
  {
    "last_brief": "<timestamp or null>",
    "last_review": "<timestamp or null>",
    "last_sync": {...},
    "carried_forward": [...],
    "weekly_intentions": {...}
  }
```

### T12.18: Update last_brief
**Code type:** Python script

```pseudo
GIVEN morning brief completed at 08:30
WHEN update_state("last_brief", "2025-01-31T08:30:00+01:00")
THEN state.json last_brief updated
```

### T12.19: Track carried forward items
**Code type:** Python script

```pseudo
GIVEN items carried from evening review
WHEN store_carried_forward(["Task A", "Task B"])
THEN state.json carried_forward contains both items
```

### T12.20: Clear carried forward after addressed
**Code type:** Python script

```pseudo
GIVEN carried_forward contains "Task A"
AND task addressed in morning brief
WHEN clear_carried_forward("Task A")
THEN item removed from state.json
```

---

## Test Suite: Pending Queue

### T12.21: Pending queue structure
**Code type:** Python script

```pseudo
GIVEN 9_Meta/pending.json
THEN contains:
  {
    "pending": [
      {
        "type": "task|reminder|suggestion",
        "content": "...",
        "source": "...",
        "created": "<timestamp>"
      }
    ]
  }
```

### T12.22: Add to pending queue
**Code type:** Python script

```pseudo
GIVEN task detected but not yet created
WHEN add_to_pending({type: "task", content: "Review proposal"})
THEN item added to pending.json pending array
```

### T12.23: Process pending item
**Code type:** Python script

```pseudo
GIVEN item in pending queue
WHEN process_pending(item_id)
THEN item removed from pending.json
AND action taken (task created, etc.)
```

### T12.24: Show pending in brief
**Code type:** Python script

```pseudo
GIVEN 2 items in pending queue
WHEN generating morning brief
THEN includes:
  "**Pending actions:**
   - Create task: Review proposal
   - Create reminder: Call dentist"
```

---

## Test Suite: Memory Queries

### T12.25: Query memory via natural language
**Code type:** Prompt/Response

```pseudo
GIVEN user asks: "What are my preferences?"
WHEN Claude processes
THEN reads memory.md and responds with preferences summary
```

### T12.26: Update memory via natural language
**Code type:** Prompt/Response

```pseudo
GIVEN user says: "Remember that Jane prefers email over Slack"
WHEN Claude processes
THEN stores in appropriate location:
  - If about user: memory.md
  - If about person: jane-smith.md
```

### T12.27: Forget specific memory
**Code type:** Prompt/Response

```pseudo
GIVEN user says: "Forget my meeting time preference"
WHEN Claude processes
THEN removes preference from memory.md
AND confirms: "Removed meeting time preference"
```

---

## Test Suite: Cross-Session Continuity

### T12.28: Resume context from previous session
**Code type:** Prompt/Response

```pseudo
GIVEN previous session ended while discussing pricing
AND context stored: "Discussing Q1 pricing strategy"
WHEN new session starts
THEN Claude can reference: "Last time we were discussing Q1 pricing..."
```

### T12.29: Track conversation topics
**Code type:** Python script

```pseudo
GIVEN conversation about domain pricing
WHEN session ends
THEN topic stored for future reference
```

---

## Test Suite: Error Handling

### T12.30: Handle missing memory file
**Code type:** Python script

```pseudo
GIVEN 9_Meta/memory.md doesn't exist
WHEN accessing memory
THEN file created with default structure
AND continues without error
```

### T12.31: Handle corrupted state.json
**Code type:** Python script

```pseudo
GIVEN state.json contains invalid JSON
WHEN accessing state
THEN backup created: state.json.bak
AND fresh state.json created
AND warning logged
```

### T12.32: Handle concurrent access
**Code type:** Python script

```pseudo
GIVEN two processes try to update state.json
WHEN concurrent write attempted
THEN file locking prevents corruption
OR last-write-wins with merge
```

---

## Mock Fixtures

### memory.md
```markdown
---
type: memory
created: 2025-01-01T10:00:00+01:00
updated: 2025-01-31T08:30:00+01:00
---

## Preferences

- **Brief time:** mornings around 08:00
- **Meeting preference:** mornings preferred
- **Response style:** concise, actionable

## Context

- Currently focused on Q1 domain pricing launch
- Main project: domain-bundling
- Key contacts: Jane Smith (Verisign), Legal team

## Patterns

- Pricing content typically → domain-bundling project
- Meeting notes usually filed to project folders
- Captures from Slack often become tasks

## Recent Focus

- domain-bundling project
- jane-smith contact
- pricing-analysis note
```

### state.json
```json
{
  "last_brief": "2025-01-31T08:30:00+01:00",
  "last_review": "2025-01-30T21:00:00+01:00",
  "last_sync": {
    "gmail": "2025-01-31T08:00:00+01:00",
    "calendar": "2025-01-31T08:00:00+01:00",
    "linear": "2025-01-31T08:00:00+01:00"
  },
  "carried_forward": [
    "Send pricing doc"
  ],
  "weekly_intentions": {
    "week": "2025-W05",
    "intentions": ["Focus on pricing launch"],
    "set_at": "2025-01-26T20:00:00+01:00"
  }
}
```

### pending.json
```json
{
  "pending": [
    {
      "id": "pend-001",
      "type": "task",
      "content": "Review proposal from Legal",
      "source": "email",
      "created": "2025-01-31T09:00:00+01:00"
    }
  ]
}
```
