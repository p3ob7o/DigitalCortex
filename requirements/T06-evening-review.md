# T06: Evening Review — Tests

## Test Environment

```
test-vault-populated/          ← With today's daily note, inbox items
```

**Mocks:**
- All external sources (for refreshing)
- User input (interactive flow)
- System clock: 2025-01-31T20:00:00+01:00

---

## Test Suite: Trigger Recognition

### T06.1: CLI trigger: claude review
**Code type:** Bash script

```pseudo
GIVEN valid vault configuration
WHEN executing: claude review
THEN evening_review() function is invoked
AND exit code is 0
```

### T06.2: Slash command triggers
**Code type:** Prompt/Response

```pseudo
FOR EACH command in ["/review", "/evening", "/pm"]:
  GIVEN active Claude session
  WHEN user sends: $command
  THEN evening review is triggered
```

### T06.3: Natural language trigger
**Code type:** Prompt/Response

```pseudo
FOR EACH phrase in:
  - "Let's do the evening review"
  - "End of day review"
  - "Wrap up the day"
  - "Close out today"
GIVEN active Claude session
WHEN user sends: $phrase
THEN Claude recognizes as evening review request
```

---

## Test Suite: Day Summary

### T06.4: Show calendar summary for today
**Code type:** Python script

```pseudo
GIVEN today had 3 calendar events
WHEN generating day summary
THEN output includes:
  "**Today's meetings:**
   - 10:00 Weekly Standup ✓
   - 14:00 1:1 with Jane ✓
   - 16:00 Team sync ✓"
```

### T06.5: Show completed tasks
**Code type:** Python script

```pseudo
GIVEN 2 Linear tasks completed today
AND 1 reminder completed
WHEN generating day summary
THEN output includes:
  "**Completed:**
   - [x] Review mockups (DOMAIN-123)
   - [x] Send report (TOTORO-12)
   - [x] Call dentist"
```

### T06.6: Reference morning brief items
**Code type:** Python script

```pseudo
GIVEN morning brief had 3 suggested priorities
WHEN generating day summary
THEN shows status of each:
  "**Morning priorities:**
   - ✓ Respond to Legal — completed
   - ✓ Slack catch-up — done
   - ○ Pricing doc — not done"
```

---

## Test Suite: Inbox Triage

### T06.7: Present inbox items one by one
**Code type:** Prompt/Response

```pseudo
GIVEN 3 items in 0_Inbox/ (excluding daily note)
WHEN interactive triage begins
THEN Claude presents first item:
  "**Item 1 of 3:**
   slack-domain-discussion.md
   Captured: 14:30 today
   Source: Slack #domain-strategy
   
   [content preview]
   
   Suggested: File to 3_Projects/domain-bundling
   
   [a]ccept / [p]roject / [r]ea / [f]leeting / [d]iscard / [s]kip?"
```

### T06.8: Suggest destination based on content
**Code type:** Prompt/Response

```pseudo
GIVEN capture mentioning "pricing" and "domain bundling"
AND project "domain-bundling" exists
WHEN presenting item
THEN suggested destination = "3_Projects/domain-bundling"
AND rationale: "Mentions pricing, related to Domain Bundling project"
```

### T06.9: Accept suggestion
**Code type:** Python script

```pseudo
GIVEN user responds "a" (accept)
AND suggestion was 3_Projects/domain-bundling
WHEN processing response
THEN file moved to 3_Projects/domain-bundling/
AND file's updated timestamp refreshed
```

### T06.10: File to different project
**Code type:** Prompt/Response

```pseudo
GIVEN user responds "p" (different project)
THEN Claude asks: "Which project?"
AND lists available projects
WHEN user selects project
THEN file moved there
```

### T06.11: File to area
**Code type:** Prompt/Response

```pseudo
GIVEN user responds "r" (area)
THEN Claude asks: "Which area?"
AND lists available areas
WHEN user selects "domaison"
THEN file moved to 4_Areas/domaison/ (or linked)
```

### T06.12: Create fleeting note
**Code type:** Python script

```pseudo
GIVEN user responds "f" (fleeting)
WHEN processing response
THEN file moved to 1_Fleeting/
AND type in frontmatter changed to "fleeting"
```

### T06.13: Discard item
**Code type:** Prompt/Response

```pseudo
GIVEN user responds "d" (discard)
THEN Claude confirms: "Delete slack-domain-discussion.md? [y/n]"
WHEN user confirms
THEN file deleted
```

### T06.14: Skip item
**Code type:** Python script

```pseudo
GIVEN user responds "s" (skip)
THEN file unchanged
AND moves to next item
AND skipped item remains in inbox
```

### T06.15: Extract task from capture
**Code type:** Prompt/Response

```pseudo
GIVEN capture contains actionable item
AND user chooses "extract task"
THEN Claude asks: "What's the task?"
AND creates Linear issue or reminder
AND optionally files or discards original capture
```

### T06.16: Extract reminder from capture
**Code type:** Prompt/Response

```pseudo
GIVEN user chooses to extract reminder
THEN Claude asks for reminder details
AND creates reminder in Apple Reminders
```

---

## Test Suite: Open Loops Review

### T06.17: Show morning brief items not completed
**Code type:** Python script

```pseudo
GIVEN morning brief had priority: "Send pricing doc"
AND no completion indicator found
WHEN generating open loops section
THEN output includes:
  "**Open from this morning:**
   - Send pricing doc — not completed
   
   What happened? [c]omplete now / [t]omorrow / [d]rop"
```

### T06.18: Carry forward to tomorrow
**Code type:** Prompt/Response

```pseudo
GIVEN open loop item
AND user chooses "tomorrow"
THEN item noted for tomorrow's brief
AND user can add note about why
```

### T06.19: Mark as completed
**Code type:** Prompt/Response

```pseudo
GIVEN open loop item
AND user says "actually I did this"
WHEN processing
THEN item marked complete
AND not carried forward
```

### T06.20: Drop item
**Code type:** Prompt/Response

```pseudo
GIVEN open loop item
AND user chooses "drop"
THEN Claude asks: "Remove from tracking? [y/n]"
WHEN confirmed
THEN item not carried forward
```

---

## Test Suite: Tomorrow Preview

### T06.21: Show tomorrow's calendar
**Code type:** Python script

```pseudo
GIVEN tomorrow has 2 calendar events
WHEN generating tomorrow preview
THEN output shows:
  "**Tomorrow (Saturday, Feb 1):**
   - 09:00 Team offsite
   - 14:00 Coffee with mentor"
```

### T06.22: Show tasks due tomorrow
**Code type:** Python script

```pseudo
GIVEN Linear task due tomorrow
WHEN generating tomorrow preview
THEN output includes task
```

### T06.23: Suggest time blocking
**Code type:** Prompt/Response

```pseudo
GIVEN carried forward items
AND tomorrow has open blocks
WHEN generating preview
THEN Claude suggests:
  "Block time for 'Send pricing doc' tomorrow?
   Open slots: 10:00-12:00, 15:00-17:00"
```

---

## Test Suite: Close Out

### T06.24: Set processed=true when inbox clear
**Code type:** Python script

```pseudo
GIVEN all inbox items triaged (none remaining)
WHEN close_out() is called
THEN daily note frontmatter: processed = true
```

### T06.25: Do NOT set processed if items skipped
**Code type:** Python script

```pseudo
GIVEN 1 inbox item was skipped
WHEN close_out() is called
THEN daily note frontmatter: processed = false
```

### T06.26: Set review_completed=true
**Code type:** Python script

```pseudo
GIVEN evening review completed fully
WHEN close_out() is called
THEN daily note frontmatter: review_completed = true
```

### T06.27: Write to Evening Review section
**Code type:** Python script

```pseudo
GIVEN review completed with notes
WHEN close_out() is called
THEN daily note ## Evening Review section populated with:
  - Completion summary
  - Carried forward items
  - Tomorrow notes
```

### T06.28: Trigger archival check
**Code type:** Python script

```pseudo
GIVEN review_completed = true
AND processed = true
AND date is past (review completed after midnight for yesterday)
WHEN close_out() finishes
THEN archive_daily_notes() is triggered
AND eligible notes moved to archive
```

---

## Test Suite: State Management

### T06.29: Update last_review timestamp
**Code type:** Python script

```pseudo
GIVEN state.json has last_review: null
WHEN evening_review() completes
THEN state.json last_review = current timestamp
```

### T06.30: Record carried forward items
**Code type:** Python script

```pseudo
GIVEN items carried to tomorrow
WHEN close_out() is called
THEN state.json includes:
  carried_forward: ["Send pricing doc", "Review contract"]
AND these surface in tomorrow's brief
```

---

## Test Suite: Interactive Mode Behavior

### T06.31: Interactive mode required
**Code type:** Prompt/Response

```pseudo
GIVEN evening review started
THEN Claude does NOT auto-process items
AND waits for user input on each decision
```

### T06.32: Allow batch operations
**Code type:** Prompt/Response

```pseudo
GIVEN 5 inbox items
WHEN user says "discard all"
THEN Claude confirms: "Discard all 5 items? [y/n]"
AND processes if confirmed
```

### T06.33: Allow exit mid-review
**Code type:** Prompt/Response

```pseudo
GIVEN user says "stop" or "exit" during review
THEN Claude asks: "Save progress? [y/n]"
AND sets appropriate flags based on progress
```

---

## Test Suite: Error Handling

### T06.34: Handle no inbox items
**Code type:** Python script

```pseudo
GIVEN 0_Inbox/ is empty (except daily note)
WHEN starting evening review
THEN skips inbox triage section
AND shows: "Inbox clear! 🎉"
```

### T06.35: Handle missing morning brief
**Code type:** Python script

```pseudo
GIVEN today's daily note has no morning brief content
WHEN generating open loops section
THEN skips "from this morning" section
AND continues with rest of review
```

---

## Mock Fixtures

### Inbox items for triage
```
test-vault-populated/0_Inbox/
├── 2025-01-31 Friday.md              # Today's daily note (not triaged)
├── slack-domain-discussion.md        # To be triaged
├── voice-memo-2025-01-31-1430.md     # To be triaged
└── web-pricing-article.md            # To be triaged
```

### User input mock
```python
MOCK_USER_RESPONSES = [
    "a",  # Accept suggestion for item 1
    "f",  # File as fleeting for item 2
    "d", "y",  # Discard item 3, confirm
]
```
