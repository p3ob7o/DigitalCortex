# F8: Inbox Processing

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F8 |
| Priority | Phase 2 (Capture & Processing) |
| Dependencies | F1, F2, F3, F4 |
| Dependents | F6 (uses same triage logic) |

## Purpose

On-demand triage of inbox items outside scheduled reviews. This allows processing captures at any time without waiting for the evening review.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F8.1 | Triggers: `claude process`, `/process`, `/inbox`, natural language | Must |
| F8.2 | Mode: Interactive | Must |
| F8.3 | Process all items in 0_Inbox except today's daily note | Must |
| F8.4 | Also process captured items in today's daily note | Must |
| F8.5 | Show item content and suggest destination | Must |
| F8.6 | Wait for user decision before proceeding | Must |
| F8.7 | Track what was processed in session | Should |
| F8.8 | Update `processed` flag on daily notes when inbox clear | Must |

---

## Scope

What gets processed:

| Item | Included |
|------|----------|
| Today's daily note | Captured items section only |
| Past daily notes (unprocessed) | Entire note |
| Standalone files in 0_Inbox | All |
| Files in subfolders of 0_Inbox | No (reserved for future use) |

---

## Processing Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    GATHER ITEMS                             │
│  Scan 0_Inbox for unprocessed items                         │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  FOR EACH ITEM                              │
│                                                             │
│  1. Present: Show source, timestamp, content preview        │
│  2. Suggest: Recommend destination with reasoning           │
│  3. Confirm: Wait for user approval or alternative          │
│  4. Execute: Move/create as confirmed                       │
│                                                             │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    UPDATE STATE                             │
│  Set processed=true on cleared daily notes                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Interactive Session

```
Starting inbox processing.

Found 5 items to process:
  • 2 from today's captures
  • 1 standalone file
  • 2 from yesterday's daily note (unprocessed)

ITEM 1 of 5
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Source: Slack (today, 09:15)
File: slack-thread-pricing-discussion.md

Content preview:
  Thread in #domain-strategy about Q1 pricing targets.
  Key points:
  - Legal approved revised terms
  - Need to update documentation
  - Launch target: Feb 15

Suggestion: File → Projects/domain-bundling
Reasoning: Mentions pricing and launch date, directly related 
           to active project.

Options:
  [a] Accept suggestion
  [p] File to different project
  [f] Move to Fleeting
  [r] Move to Resources
  [t] Extract task
  [d] Discard
  [s] Skip for now

Your choice: _
```

---

## Triage Options

| Option | Key | Destination | Description |
|--------|-----|-------------|-------------|
| Accept | `a` | As suggested | Use Claude's recommendation |
| Different project | `p` | `3_Projects/{name}/` | Prompt for project name |
| Area | `r` | `4_Areas/` | File under an area (less common) |
| Fleeting | `f` | `1_Fleeting/` | Needs more thought |
| Resource | `r` | `5_Resources/` | Reference material |
| Extract task | `t` | Linear (Totoro) | Create task, optionally keep note |
| Extract reminder | `m` | Apple Reminders | Create reminder |
| Discard | `d` | Delete | Not worth keeping |
| Skip | `s` | Leave in inbox | Decide later |

---

## Suggestion Logic

Claude suggests destinations based on:

### Content Analysis
- Keywords matching project names
- Mentions of people (→ link to People file)
- Technical terms matching Areas
- URLs (→ likely Resource)

### Metadata
- Source (Slack channel → likely project context)
- Sender (known person → check their areas)
- Date (old capture → might be stale)

### Examples

| Content Signal | Suggested Destination |
|----------------|----------------------|
| Mentions "domain-bundling" | Projects/domain-bundling |
| From @jane about pricing | Projects/domain-bundling + update Jane's last_contact |
| Link to external article | Resources |
| "Idea for..." or "What if..." | Fleeting |
| "Need to..." or "Don't forget..." | Extract task/reminder |
| Screenshot of UI | Assets (linked from relevant project) |

---

## Task/Reminder Extraction

When extracting an actionable item:

```
EXTRACT TASK

Original content:
  "Need to update the pricing documentation before 
   the Feb 15 launch."

Suggested task:
  Title: Update pricing documentation
  Project: domain-bundling
  Due: 2025-02-14 (day before launch)

Create this task in Linear (Totoro)?
  [y] Yes
  [e] Edit first
  [n] No, keep as note only
```

---

## Handling Past Daily Notes

If there are unprocessed daily notes from previous days:

```
Found unprocessed daily note: 2025-01-30 Thursday.md

This note has 3 captured items that weren't processed.
Process them now?

  [y] Yes, include in this session
  [l] Process later
  [a] Archive anyway (items weren't important)
```

---

## Session Summary

At the end of processing:

```
PROCESSING COMPLETE

Session summary:
  • 3 items filed to Projects
  • 1 item moved to Fleeting
  • 1 task created in Linear
  • 0 discarded

Inbox status:
  ✓ Today's inbox: clear
  ✓ Yesterday's note: now processed, ready for archive

Anything else you'd like to do?
```

---

## State Updates

### Daily Note Flags

| Condition | Action |
|-----------|--------|
| All captures in daily note processed | Set `processed=true` |
| Some items skipped | Leave `processed=false` |
| Past daily note fully processed | Move to archive |

### Timestamps

- `updated` field refreshed on any modified file
- `last_contact` updated on People files when relevant

---

## Template

The inbox processing behavior is defined in `9_Meta/prompts/process-inbox.md`:

```markdown
---
name: process-inbox
mode: interactive
triggers:
  - /process
  - /inbox
---

## Purpose
Triage inbox items outside of scheduled reviews.

## Scope
- All items in 0_Inbox except today's daily note structure
- Captured items section of today's daily note
- Unprocessed past daily notes

## For Each Item
1. Present (source, timestamp, preview)
2. Suggest (destination with reasoning)
3. Confirm (wait for decision)
4. Execute (move/create, update timestamps)

## Behavior
- One item at a time
- Show reasoning for each suggestion
- Track session progress
- Update daily note flags when appropriate
```

---

## Validation

| Check | Expected |
|-------|----------|
| All inbox items presented | ✓ |
| Suggestions include reasoning | ✓ |
| User decision required | ✓ |
| Files moved to correct location | ✓ |
| Timestamps updated | ✓ |
| Daily note flags set correctly | ✓ |

---

## Related Features

- **F2 (Capture)**: Creates items to process
- **F3 (Daily Note)**: Contains captures, receives flag updates
- **F6 (Evening Review)**: Uses same triage logic
- **F9 (Task Management)**: Destination for extracted tasks
