# T07: Weekly Review — Tests

## Test Environment

```
test-vault-populated/          ← With week's worth of daily notes, projects, fleeting notes
```

**Mocks:**
- Calendar API (past week + next week)
- Linear API (completed + open)
- User input (interactive flow)
- System clock: 2025-02-02 (Sunday)

---

## Test Suite: Trigger Recognition

### T07.1: CLI trigger: claude weekly
**Code type:** Bash script

```pseudo
GIVEN valid vault configuration
AND today is Sunday
WHEN executing: claude weekly
THEN weekly_review() function is invoked
```

### T07.2: Slash command triggers
**Code type:** Prompt/Response

```pseudo
FOR EACH command in ["/weekly", "/week"]:
  GIVEN active Claude session
  WHEN user sends: $command
  THEN weekly review is triggered
```

### T07.3: Natural language trigger
**Code type:** Prompt/Response

```pseudo
FOR EACH phrase in:
  - "Let's do the weekly review"
  - "Weekly review time"
  - "Review the week"
GIVEN active Claude session
WHEN user sends: $phrase
THEN Claude recognizes as weekly review request
```

### T07.4: Non-Sunday warning
**Code type:** Prompt/Response

```pseudo
GIVEN today is Wednesday
WHEN user triggers weekly review
THEN Claude notes: "Weekly review is typically done on Sundays. Continue anyway? [y/n]"
```

---

## Test Suite: Week in Review

### T07.5: Show past week's highlights
**Code type:** Python script

```pseudo
GIVEN 7 archived daily notes for the week
WHEN generating week review
THEN output includes:
  "**This Week (Jan 27 - Feb 2):**
   - Monday: 3 meetings, completed Domain-123
   - Tuesday: Deep work day, 2 tasks completed
   ..."
```

### T07.6: Aggregate completed tasks
**Code type:** Python script

```pseudo
GIVEN Linear shows 8 tasks completed this week
WHEN generating completions summary
THEN output shows:
  "**Completed this week:** 8 tasks
   - DOMAIN-123: Review mockups
   - DOMAIN-124: Update docs
   ..."
```

### T07.7: Identify patterns
**Code type:** Prompt/Response

```pseudo
GIVEN week's calendar data
WHEN analyzing patterns
THEN Claude identifies:
  "**Patterns noticed:**
   - Most productive: Tuesday (4 tasks)
   - Meeting-heavy: Thursday (5 meetings)
   - Context switches: 12 across the week"
```

### T07.8: Calculate calendar metrics
**Code type:** Python script

```pseudo
GIVEN week's calendar events
WHEN calculating metrics
THEN output includes:
  - Total meeting hours
  - Average meetings per day
  - Longest focus block
```

---

## Test Suite: Projects Status

### T07.9: List all active projects
**Code type:** Python script

```pseudo
GIVEN 3_Projects/ contains 5 project folders
AND 3 have status: active
WHEN generating projects status
THEN shows all 3 active projects
```

### T07.10: Show project progress indicators
**Code type:** Python script

```pseudo
GIVEN project with Linear mapping
AND Linear shows 5/10 tasks complete
WHEN generating project status
THEN output includes: "Domain Bundling — 50% (5/10 tasks)"
```

### T07.11: Ask about each project status
**Code type:** Prompt/Response

```pseudo
FOR EACH active project:
  GIVEN project presented in review
  THEN Claude asks:
    "**Domain Bundling** (5/10 tasks)
     Still accurate? Any blockers?
     [y] Yes, on track / [u] Update status / [p] Pause / [d] Drop"
```

### T07.12: Update project status
**Code type:** Python script

```pseudo
GIVEN user chooses to update project status
AND provides new status
WHEN processing update
THEN project frontmatter status updated
AND updated timestamp refreshed
```

### T07.13: Identify stalled projects
**Code type:** Python script

```pseudo
GIVEN project with no activity in 14+ days
WHEN generating project status
THEN project flagged: "⚠ No activity for 14 days"
```

---

## Test Suite: Fleeting Notes Triage

### T07.14: List fleeting notes older than 7 days
**Code type:** Python script

```pseudo
GIVEN 1_Fleeting/ contains:
  - note-1.md (created 3 days ago)
  - note-2.md (created 10 days ago)
  - note-3.md (created 8 days ago)
WHEN generating fleeting notes section
THEN only note-2 and note-3 presented (>7 days)
```

### T07.15: Present each old fleeting for decision
**Code type:** Prompt/Response

```pseudo
GIVEN fleeting note older than 7 days
THEN Claude presents:
  "**Fleeting note (10 days old):**
   [content preview]
   
   Decision needed:
   [p]roject / [a]rea / [r]esource / [d]elete / [k]eep as fleeting"
```

### T07.16: Convert fleeting to resource
**Code type:** Python script

```pseudo
GIVEN user chooses "resource" for fleeting note
WHEN processing decision
THEN file moved to 5_Resources/
AND frontmatter type changed to "resource"
```

### T07.17: Delete stale fleeting
**Code type:** Python script

```pseudo
GIVEN user chooses "delete" for fleeting note
AND confirms deletion
WHEN processing
THEN file deleted from 1_Fleeting/
```

---

## Test Suite: Calendar Preview

### T07.18: Show next week's calendar
**Code type:** Python script

```pseudo
GIVEN next week has events
WHEN generating calendar preview
THEN output shows each day with events:
  "**Next Week:**
   - Mon Feb 3: 2 meetings
   - Tue Feb 4: Team offsite (all day)
   - Wed Feb 5: 3 meetings
   ..."
```

### T07.19: Identify busy days
**Code type:** Python script

```pseudo
GIVEN Tuesday has 6 hours of meetings
WHEN analyzing next week
THEN flags: "⚠ Tuesday: 6h meetings, limited focus time"
```

### T07.20: Suggest preparation for big events
**Code type:** Prompt/Response

```pseudo
GIVEN event "Board Presentation" on Thursday
WHEN generating preview
THEN Claude suggests:
  "Board Presentation on Thursday — prep needed?
   [c] Create prep task / [n] No prep needed"
```

---

## Test Suite: Themes and Intentions

### T07.21: Ask for weekly intentions
**Code type:** Prompt/Response

```pseudo
GIVEN end of weekly review
THEN Claude asks:
  "What do you want to focus on this week?
   (These will show in Monday's brief)"
```

### T07.22: Record intentions in state
**Code type:** Python script

```pseudo
GIVEN user provides intentions: "Focus on pricing launch"
WHEN recording intentions
THEN state.json updated:
  weekly_intentions: {
    week: "2025-W05",
    intentions: ["Focus on pricing launch"],
    set_at: <timestamp>
  }
```

### T07.23: Surface intentions in Monday brief
**Code type:** Python script

```pseudo
GIVEN weekly_intentions set for current week
WHEN generating Monday's morning brief
THEN brief includes:
  "**Weekly intention:** Focus on pricing launch"
```

---

## Test Suite: Output Options

### T07.24: Option to create weekly review note
**Code type:** Prompt/Response

```pseudo
GIVEN weekly review completed
THEN Claude asks:
  "Save weekly review as note? [y/n]"
```

### T07.25: Create weekly review note
**Code type:** Python script

```pseudo
GIVEN user confirms saving
WHEN creating note
THEN file created: 6_Archive/Weekly-Reviews/2025-W05.md
AND contains:
  - Week summary
  - Completions
  - Project status
  - Intentions
```

### T07.26: Weekly review note has correct frontmatter
**Code type:** Python script

```pseudo
GIVEN weekly review note created
THEN frontmatter contains:
  type: weekly-review
  week: 2025-W05
  date_range: 2025-01-27 to 2025-02-02
  created: <timestamp>
```

---

## Test Suite: Interactive Flow

### T07.27: Full interactive flow
**Code type:** Prompt/Response

```pseudo
GIVEN weekly review triggered
THEN flow proceeds through sections:
  1. Week in review (summary, can ask questions)
  2. Projects status (each project reviewed)
  3. Fleeting notes (each old note triaged)
  4. Calendar preview (review, create tasks)
  5. Themes/intentions (set for next week)
  6. Close out (save note option)
```

### T07.28: Allow section skipping
**Code type:** Prompt/Response

```pseudo
GIVEN in projects section
WHEN user says "skip projects"
THEN moves to fleeting notes section
AND projects unchanged
```

### T07.29: Allow early exit
**Code type:** Prompt/Response

```pseudo
GIVEN user says "stop" mid-review
THEN Claude asks: "Save progress made so far? [y/n]"
AND exits gracefully
```

---

## Test Suite: Error Handling

### T07.30: Handle no daily notes for week
**Code type:** Python script

```pseudo
GIVEN no archived daily notes for past week
WHEN generating week review
THEN shows: "No daily notes found for this week"
AND continues with other sections
```

### T07.31: Handle no fleeting notes
**Code type:** Python script

```pseudo
GIVEN 1_Fleeting/ is empty
WHEN reaching fleeting notes section
THEN shows: "No fleeting notes to review 🎉"
AND moves to next section
```

---

## Mock Fixtures

### Daily notes for the week
```
test-vault-populated/6_Archive/Daily-Notes/2025/01/
├── 2025-01-27 Monday.md
├── 2025-01-28 Tuesday.md
├── 2025-01-29 Wednesday.md
├── 2025-01-30 Thursday.md
└── 2025-01-31 Friday.md

test-vault-populated/0_Inbox/
├── 2025-02-01 Saturday.md
└── 2025-02-02 Sunday.md
```

### Fleeting notes of various ages
```
test-vault-populated/1_Fleeting/
├── recent-idea.md                # 3 days old (skip)
├── old-thought.md                # 10 days old (triage)
└── stale-note.md                 # 8 days old (triage)
```

### Projects with various states
```
test-vault-populated/3_Projects/
├── domain-bundling/             # active, 50% complete
├── bi-phase-1/                  # active, 80% complete
├── archive-project/             # completed
└── stalled-project/             # active but no activity 14 days
```
