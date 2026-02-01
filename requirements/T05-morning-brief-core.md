# T05: Morning Brief Core — Tests

## Test Environment

```
test-vault-populated/          ← With today's daily note
```

**Mocks:**
- All external sources (Gmail, Calendar, Slack, P2, Linear, Reminders)
- System clock: 2025-01-31T08:00:00+01:00
- User input (for interactive approval flow)

---

## Test Suite: Trigger Recognition

### T05.1: CLI trigger: claude brief
**Code type:** Bash script

```pseudo
GIVEN valid vault configuration
WHEN executing: claude brief
THEN morning_brief() function is invoked
AND exit code is 0
```

### T05.2: Slash command trigger: /brief
**Code type:** Prompt/Response

```pseudo
GIVEN active Claude session with vault context
WHEN user sends: "/brief"
THEN Claude recognizes morning brief trigger
AND responds with brief generation
```

### T05.3: Slash command aliases
**Code type:** Prompt/Response

```pseudo
FOR EACH command in ["/morning", "/am"]:
  GIVEN active Claude session
  WHEN user sends: $command
  THEN morning brief is triggered
```

### T05.4: Natural language trigger
**Code type:** Prompt/Response

```pseudo
FOR EACH phrase in:
  - "Let's do the morning brief"
  - "Start my morning routine"
  - "What's on my plate today?"
  - "Brief me on today"
GIVEN active Claude session
WHEN user sends: $phrase
THEN Claude recognizes as morning brief request
```

---

## Test Suite: Source Orchestration

### T05.5: All enabled sources are fetched
**Code type:** Python script

```pseudo
GIVEN config.yaml with all sources enabled
AND mock sources return valid data
WHEN morning_brief() is executed
THEN fetch is attempted for: gmail, calendar, slack, p2, linear, reminders
AND results aggregated into unified structure
```

### T05.6: Sources fetched in parallel
**Code type:** Python script

```pseudo
GIVEN 6 sources each taking 500ms to fetch
WHEN morning_brief() is executed
THEN total fetch time < 2000ms (not 3000ms sequential)
```

### T05.7: Disabled sources are skipped
**Code type:** Python script

```pseudo
GIVEN config.yaml with slack.enabled: false
WHEN morning_brief() is executed
THEN slack fetch is NOT attempted
AND brief continues without slack data
AND no error for missing slack
```

### T05.8: Graceful degradation on source failure
**Code type:** Python script

```pseudo
GIVEN gmail mock raises ConnectionError
AND calendar, slack, p2, linear, reminders return valid data
WHEN morning_brief() is executed
THEN brief is generated with available data
AND output includes warning: "⚠ Gmail unavailable"
AND exit code is 0 (not failure)
```

### T05.9: Continue with partial data
**Code type:** Python script

```pseudo
GIVEN 3 of 6 sources fail
WHEN morning_brief() is executed
THEN brief is generated from remaining 3 sources
AND all failures are reported in warnings section
```

---

## Test Suite: Output Structure

### T05.10: Brief written to daily note
**Code type:** Python script

```pseudo
GIVEN morning_brief() completes successfully
THEN today's daily note (0_Inbox/2025-01-31 Friday.md)
  has content under ## Morning Brief section
```

### T05.11: Output has correct sections
**Code type:** Python script

```pseudo
GIVEN morning_brief() generates output
THEN output contains sections in order:
  1. Calendar
  2. Completed Since Yesterday
  3. Emails Requiring Attention
  4. Slack & P2
  5. Tasks & Reminders
  6. Suggested Priorities
  7. Decisions Needed
```

### T05.12: Empty sections omitted gracefully
**Code type:** Python script

```pseudo
GIVEN no emails to report (gmail returns empty)
WHEN brief is generated
THEN "Emails Requiring Attention" section shows:
  "No emails requiring attention" or is omitted
AND does not show empty section
```

### T05.13: Brief includes date header
**Code type:** Python script

```pseudo
GIVEN mock date is 2025-01-31
WHEN brief is generated
THEN output starts with:
  "## Morning Brief — Friday, January 31"
  or similar date-formatted header
```

---

## Test Suite: Priority Synthesis

### T05.14: Priorities extracted from multiple sources
**Code type:** Python script

```pseudo
GIVEN:
  - Email with "URGENT" in subject
  - Linear task due today
  - Reminder due today
WHEN brief synthesizes priorities
THEN "Suggested Priorities" section includes items from all three sources
```

### T05.15: Priority ordering by urgency
**Code type:** Python script

```pseudo
GIVEN:
  - Task due in 3 days
  - Task due today
  - Task marked URGENT
WHEN priorities are generated
THEN order is: URGENT first, due today second, due in 3 days third
```

### T05.16: Each priority includes rationale
**Code type:** Prompt/Response

```pseudo
GIVEN priority item: "Respond to Legal on pricing"
WHEN brief is generated
THEN priority entry includes rationale text explaining WHY it's important
EXAMPLE:
  "1. **Respond to Legal on pricing** — blocking domain-bundling launch"
```

### T05.17: Time slot suggestions based on calendar
**Code type:** Python script

```pseudo
GIVEN calendar shows:
  - 10:00-10:30 Meeting
  - 14:00-15:00 Meeting
AND 3 priority items
WHEN priorities are generated
THEN suggested time slots are:
  - 08:00-09:45 (before first meeting with buffer)
  - 10:30-13:45 (between meetings)
  - 15:00+ (after meetings)
AND each priority assigned to a slot
```

### T05.18: Respect meeting buffers in time slots
**Code type:** Python script

```pseudo
GIVEN meeting at 10:00
AND config buffer_minutes: 15
WHEN calculating open blocks
THEN block before meeting ends at 09:45, not 10:00
```

---

## Test Suite: Interactive Mode

### T05.19: Brief presented for review before writing
**Code type:** Prompt/Response

```pseudo
GIVEN morning_brief() in interactive mode
WHEN brief is ready
THEN Claude presents brief in terminal
AND asks for approval before writing to file
```

### T05.20: User can accept suggestion
**Code type:** Prompt/Response

```pseudo
GIVEN brief presented with priority suggestions
WHEN user responds: "accept" or "a"
THEN suggestion is recorded as-is
AND brief proceeds to next item or writes final
```

### T05.21: User can modify suggestion
**Code type:** Prompt/Response

```pseudo
GIVEN brief presented with suggested priority:
  "Respond to Legal — suggested 08:30-09:30"
WHEN user responds: "modify to 11:00"
THEN suggestion updated with new time
AND brief reflects modification
```

### T05.22: User can skip suggestion
**Code type:** Prompt/Response

```pseudo
GIVEN brief presented with priority
WHEN user responds: "skip" or "s"
THEN priority is omitted from final brief
AND proceeds to next item
```

### T05.23: Brief writes only after approval
**Code type:** Python script

```pseudo
GIVEN brief generation complete
AND user has not approved
THEN daily note ## Morning Brief section is unchanged
WHEN user approves
THEN content is written to daily note
```

---

## Test Suite: State Management

### T05.24: Update last_brief timestamp
**Code type:** Python script

```pseudo
GIVEN state.json has last_brief: null
WHEN morning_brief() completes successfully
THEN state.json last_brief updated to current timestamp
```

### T05.25: Use last_brief for "since" queries
**Code type:** Python script

```pseudo
GIVEN state.json last_brief: "2025-01-30T08:00:00+01:00"
WHEN querying sources for "since last brief"
THEN queries use this timestamp as lower bound
```

### T05.26: Handle first brief (no previous timestamp)
**Code type:** Python script

```pseudo
GIVEN state.json last_brief: null (first run)
WHEN morning_brief() is executed
THEN uses reasonable default (last 24 hours)
AND does not error on missing timestamp
```

---

## Test Suite: Error Handling

### T05.27: Handle missing daily note
**Code type:** Bash script

```pseudo
GIVEN no daily note exists for today
WHEN morning_brief() is executed
THEN daily note is created first
AND brief is written to it
```

### T05.28: Handle invalid config
**Code type:** Bash script

```pseudo
GIVEN config.yaml is malformed YAML
WHEN morning_brief() is executed
THEN exits with clear error: "Invalid configuration"
AND does not partially write brief
```

### T05.29: Handle all sources failing
**Code type:** Python script

```pseudo
GIVEN all 6 source mocks raise errors
WHEN morning_brief() is executed
THEN generates minimal brief with local data only
AND reports all failures
AND suggests: "Run /sync to retry connections"
```

---

## Test Fixtures Required

### Mock source responses
```python
# mock_sources.py
MOCK_GMAIL = {
    "emails": [
        {"from": "jane@verisign.com", "subject": "RE: Pricing", "unread": True},
        {"from": "legal@automattic.com", "subject": "Contract Review", "starred": True}
    ]
}

MOCK_CALENDAR = {
    "events": [
        {"summary": "Weekly Standup", "start": "10:00", "end": "10:30"},
        {"summary": "1:1 with Jane", "start": "14:00", "end": "15:00"}
    ]
}

MOCK_LINEAR = {
    "active": [{"identifier": "DOMAIN-123", "title": "Update pricing", "due": "2025-01-31"}],
    "completed": [{"identifier": "DOMAIN-100", "title": "Review mockups"}]
}

MOCK_REMINDERS = {
    "due_today": [{"title": "Call dentist", "time": "10:00"}],
    "overdue": []
}

MOCK_SLACK = {
    "mentions": [{"channel": "#domain-strategy", "from": "@colleague", "text": "thoughts on Q1?"}]
}

MOCK_P2 = {
    "mentions": [{"site": "domain-team", "title": "Weekly Notes", "mention": "@paolo"}]
}
```

### state.json fixture
```json
{
  "last_brief": "2025-01-30T08:00:00+01:00",
  "last_review": "2025-01-30T21:00:00+01:00",
  "last_sync": {
    "gmail": "2025-01-31T07:55:00+01:00",
    "calendar": "2025-01-31T07:55:00+01:00",
    "slack": "2025-01-31T07:55:00+01:00",
    "p2": "2025-01-31T07:55:00+01:00",
    "linear": "2025-01-31T07:55:00+01:00",
    "reminders": "2025-01-31T07:55:00+01:00"
  }
}
```
