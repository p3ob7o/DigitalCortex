# T08: Inbox Processing — Tests

## Test Environment

```
test-vault-populated/          ← With items in 0_Inbox/ and daily notes
```

**Mocks:**
- User input (interactive flow)
- System clock: 2025-01-31T15:00:00+01:00

---

## Test Suite: Trigger Recognition

### T08.1: CLI trigger: claude process
**Code type:** Bash script

```pseudo
GIVEN valid vault with inbox items
WHEN executing: claude process
THEN inbox_processing() function is invoked
```

### T08.2: Slash command triggers
**Code type:** Prompt/Response

```pseudo
FOR EACH command in ["/process", "/inbox"]:
  GIVEN active Claude session
  WHEN user sends: $command
  THEN inbox processing is triggered
```

### T08.3: Natural language trigger
**Code type:** Prompt/Response

```pseudo
FOR EACH phrase in:
  - "Process my inbox"
  - "Let's go through the inbox"
  - "Clear the inbox"
WHEN user sends: $phrase
THEN Claude recognizes as inbox processing request
```

---

## Test Suite: Scope Identification

### T08.4: Include files in 0_Inbox (except daily notes)
**Code type:** Python script

```pseudo
GIVEN 0_Inbox/ contains:
  - 2025-01-31 Friday.md (daily note)
  - slack-capture.md
  - web-article.md
WHEN identifying inbox scope
THEN scope includes: [slack-capture.md, web-article.md]
AND excludes: 2025-01-31 Friday.md
```

### T08.5: Include captures from today's daily note
**Code type:** Python script

```pseudo
GIVEN today's daily note has ## Captures section with items
WHEN identifying inbox scope
THEN captures from daily note included in processing queue
```

### T08.6: Include unprocessed past daily notes
**Code type:** Python script

```pseudo
GIVEN 0_Inbox/ contains:
  - 2025-01-29 Wednesday.md (processed: false)
  - 2025-01-30 Thursday.md (processed: true)
WHEN identifying inbox scope
THEN 2025-01-29 note included
AND 2025-01-30 note excluded
```

### T08.7: Process oldest notes first
**Code type:** Python script

```pseudo
GIVEN unprocessed notes from Jan 28, 29, 30
WHEN ordering processing queue
THEN order is: Jan 28 first, then Jan 29, then Jan 30
```

---

## Test Suite: Item Presentation

### T08.8: Show item metadata
**Code type:** Prompt/Response

```pseudo
GIVEN inbox item: slack-domain-discussion.md
WHEN presenting item
THEN output includes:
  - Filename
  - Source (from frontmatter)
  - Captured timestamp
  - Content preview (first ~200 chars)
```

### T08.9: Suggest destination with rationale
**Code type:** Prompt/Response

```pseudo
GIVEN item content mentions "pricing" and "domain bundling"
AND project "domain-bundling" exists
WHEN presenting item
THEN suggestion:
  "Suggested: File to [[domain-bundling]]
   Rationale: Mentions pricing, relates to active Domain Bundling project"
```

### T08.10: Show triage options
**Code type:** Prompt/Response

```pseudo
GIVEN item presented
THEN options shown:
  "[a] Accept suggestion
   [p] Different project
   [r] Area
   [f] Fleeting note
   [R] Resource
   [t] Extract task
   [m] Extract reminder
   [d] Discard
   [s] Skip"
```

---

## Test Suite: Triage Actions

### T08.11: Accept suggestion
**Code type:** Python script

```pseudo
GIVEN suggestion: 3_Projects/domain-bundling
AND user responds "a"
WHEN processing
THEN file moved to 3_Projects/domain-bundling/
AND frontmatter updated timestamp refreshed
```

### T08.12: File to different project
**Code type:** Prompt/Response

```pseudo
GIVEN user responds "p"
THEN Claude lists available projects:
  "Available projects:
   1. domain-bundling
   2. bi-phase-1
   3. jetpack-update
   
   Select (number or name):"
WHEN user selects "2"
THEN file moved to 3_Projects/bi-phase-1/
```

### T08.13: File to area
**Code type:** Python script

```pseudo
GIVEN user selects area "domaison"
WHEN filing to area
THEN file moved to 4_Areas/domaison/ 
  OR linked via frontmatter areas: ["[[domaison]]"]
```

### T08.14: Convert to fleeting note
**Code type:** Python script

```pseudo
GIVEN user responds "f"
WHEN converting to fleeting
THEN file moved to 1_Fleeting/
AND frontmatter type changed to "fleeting"
AND topics field added if extractable
```

### T08.15: Convert to resource
**Code type:** Python script

```pseudo
GIVEN user responds "R"
WHEN converting to resource
THEN file moved to 5_Resources/
AND frontmatter type changed to "resource"
```

### T08.16: Extract task to Linear
**Code type:** Prompt/Response

```pseudo
GIVEN user responds "t"
THEN Claude asks:
  "What's the task title?"
WHEN user provides: "Review pricing analysis"
THEN Claude asks:
  "Due date? (enter for none)"
WHEN user provides: "Friday"
THEN task created in Linear (Totoro team)
AND Claude asks: "Keep or discard original capture?"
```

### T08.17: Extract reminder
**Code type:** Prompt/Response

```pseudo
GIVEN user responds "m"
THEN Claude asks for reminder details
AND creates in Apple Reminders
```

### T08.18: Discard with confirmation
**Code type:** Prompt/Response

```pseudo
GIVEN user responds "d"
THEN Claude confirms:
  "Delete slack-domain-discussion.md? This cannot be undone. [y/n]"
WHEN user confirms "y"
THEN file deleted
```

### T08.19: Skip item
**Code type:** Python script

```pseudo
GIVEN user responds "s"
THEN item unchanged
AND counter shows "Skipped: 1"
AND item remains in inbox
```

---

## Test Suite: Batch Operations

### T08.20: Discard all
**Code type:** Prompt/Response

```pseudo
GIVEN 5 items remaining
WHEN user says "discard all"
THEN Claude confirms:
  "Delete all 5 remaining items? [y/n]"
WHEN confirmed
THEN all 5 deleted
```

### T08.21: Skip remaining
**Code type:** Prompt/Response

```pseudo
GIVEN 3 items remaining
WHEN user says "skip rest" or "done for now"
THEN processing ends
AND 3 items remain in inbox
AND processed flag NOT set
```

---

## Test Suite: Daily Note Processing

### T08.22: Process captures from daily note
**Code type:** Python script

```pseudo
GIVEN daily note has captures:
  ### 10:00
  Quick thought about pricing
  
  ### 14:00
  [[slack-discussion.md]] - team discussion
WHEN processing daily note captures
THEN each capture presented for triage
```

### T08.23: Handle inline vs linked captures
**Code type:** Python script

```pseudo
GIVEN daily note has:
  - Inline capture (just text)
  - Linked capture ([[slack-file.md]])
WHEN processing
THEN inline: offer to extract or leave
THEN linked: process the linked file
```

### T08.24: Mark daily note processed when complete
**Code type:** Python script

```pseudo
GIVEN all captures from daily note triaged
AND no items skipped
WHEN processing completes
THEN daily note frontmatter: processed = true
```

---

## Test Suite: State Updates

### T08.25: Track processing progress
**Code type:** Python script

```pseudo
GIVEN 10 items to process
WHEN processing item 5
THEN progress indicator shows: "Item 5 of 10"
```

### T08.26: Update file timestamps on move
**Code type:** Python script

```pseudo
GIVEN file moved to project
THEN frontmatter updated field = current timestamp
```

### T08.27: Preserve file history
**Code type:** Python script

```pseudo
GIVEN capture with source: slack
WHEN filed to project
THEN frontmatter source field preserved
AND original capture timestamp preserved
```

---

## Test Suite: Error Handling

### T08.28: Handle empty inbox
**Code type:** Python script

```pseudo
GIVEN 0_Inbox/ has only today's daily note
AND no captures in daily note
WHEN starting inbox processing
THEN output: "Inbox is empty! 🎉"
AND exits gracefully
```

### T08.29: Handle file move failure
**Code type:** Python script

```pseudo
GIVEN destination folder doesn't exist
WHEN attempting to file
THEN creates destination folder
AND completes move
```

### T08.30: Handle invalid user input
**Code type:** Prompt/Response

```pseudo
GIVEN user enters "x" (invalid option)
THEN Claude responds:
  "Invalid option. Please choose: [a/p/r/f/R/t/m/d/s]"
AND re-prompts
```

---

## Mock Fixtures

### Inbox with various items
```
test-vault-populated/0_Inbox/
├── 2025-01-31 Friday.md           # Today's daily (with captures)
├── 2025-01-29 Wednesday.md        # Unprocessed past daily
├── slack-domain-discussion.md      # Slack capture
├── voice-memo-2025-01-31-1430.md   # Voice memo
├── web-pricing-article.md          # Web capture
└── email-legal-contract.md         # Email capture
```

### slack-domain-discussion.md
```yaml
---
type: capture
source: slack
channel: "#domain-strategy"
from: "@colleague"
captured: 2025-01-31T14:30:00+01:00
created: 2025-01-31T14:30:00+01:00
updated: 2025-01-31T14:30:00+01:00
---

Discussion about Q1 pricing targets and domain bundling strategy.
@colleague mentioned we should finalize the tier structure.
```
