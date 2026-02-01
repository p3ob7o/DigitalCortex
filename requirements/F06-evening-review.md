# F6: Evening Review

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F6 |
| Priority | Phase 3 (Rituals) |
| Dependencies | F1, F3, F4, F5 (Morning Brief) |
| Dependents | F7 (Weekly Review aggregates daily reviews) |

## Purpose

Reflect on the day, process remaining inbox items, close open loops from the morning brief, and prepare for tomorrow. Unlike the morning brief (which Claude prepares), the evening review is a guided conversation.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F6.1 | Triggers: `claude review`, `/review`, `/evening`, `/pm`, natural language | Must |
| F6.2 | Mode: Interactive (walk through together) | Must |
| F6.3 | Process one item at a time, wait for user decision | Must |
| F6.4 | Update daily note with Evening Review section | Must |
| F6.5 | Set `processed=true` when inbox clear | Must |
| F6.6 | Set `review_completed=true` when review done | Must |
| F6.7 | Move daily note to archive if conditions met | Must |
| F6.8 | Surface open loops from morning brief | Should |

---

## Review Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    1. DAY SUMMARY                           │
│  What was scheduled, what was completed                     │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   2. INBOX TRIAGE                           │
│  Process each item: file, extract task, or discard          │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    3. OPEN LOOPS                            │
│  Morning brief items not completed — carry forward?         │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  4. TOMORROW PREVIEW                        │
│  What's coming, any prep needed?                            │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     5. CLOSE OUT                            │
│  Update flags, archive if ready                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Interactive Session

### 1. Day Summary

```
Good evening, {{user.name}}. Let's review your day.

TODAY'S CALENDAR
  ✓ 10:00 Weekly standup
  ✓ 14:00 1:1 with Jane Smith

TASKS COMPLETED
  ✓ Respond to Legal on pricing
  ✓ Send revised pricing doc

TASKS STILL OPEN
  • Prepare Q1 review deck (due Monday)

How did today feel overall?
```

User can share reflections or skip.

---

### 2. Inbox Triage

```
Let's process what you captured today.

ITEM 1 of 3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Source: Voice memo (14:30)
Content: "Idea for transfer flow — what if we showed 
         estimated completion time upfront? Users often 
         ask about this in support tickets."

This seems related to the domain-bundling project.

Options:
  [f] File → Projects/domain-bundling
  [l] Create Fleeting note
  [t] Extract task: "Explore transfer time display"
  [d] Discard
  [s] Skip for now

Your choice: _
```

Claude waits for decision, then proceeds to next item.

---

### 3. Open Loops

```
OPEN LOOPS FROM THIS MORNING

These items from your brief weren't marked done:

1. "Address Slack thread on Q1 targets"
   → Did this happen?
   
   [c] Completed (just not tracked)
   [f] Carry forward to tomorrow
   [t] Convert to Linear task
   [d] Drop (no longer relevant)
```

---

### 4. Tomorrow Preview

```
TOMORROW: Saturday, February 1

Calendar:
  • No meetings scheduled

Upcoming tasks:
  • Prepare Q1 review deck (due Monday)

Would you like to:
  [b] Block time for specific work
  [n] Add notes/intentions for tomorrow
  [s] Skip
```

---

### 5. Close Out

```
REVIEW COMPLETE

Summary of actions:
  • Filed 2 items to Projects/domain-bundling
  • Created 1 Fleeting note
  • Carried forward 1 item to tomorrow
  • Updated last_contact for Jane Smith

Daily note status:
  ✓ processed = true
  ✓ review_completed = true

This note is ready for archive. Good night!
```

---

## Daily Note Update

The Evening Review section is added to the daily note:

```markdown
## Evening Review

### Completed
- [x] Respond to Legal on pricing
- [x] Send revised pricing doc
- [x] Weekly standup
- [x] 1:1 with Jane Smith

### Captured → Filed
- Voice memo on transfer flow → [[Projects/domain-bundling/transfer-time-idea.md]]
- Slack thread on metrics → [[1_Fleeting/metrics-discussion.md]]

### Carried Forward
- [ ] Address Slack thread on Q1 targets
- [ ] Prepare Q1 review deck (due Monday)

### Reflections
Good progress on domain bundling. The transfer time idea might be worth
exploring next sprint. Feeling more on top of things after the pricing
doc shipped.
```

---

## State Management

### Flags Updated

| Flag | When Set True |
|------|---------------|
| `processed` | All inbox items have been addressed |
| `review_completed` | Evening review flow completed |

### Archive Trigger

Daily note moves to archive when:
- `date < today` (day has passed)
- `processed = true`
- `review_completed = true`

If review happens after midnight, the original day's note is still archived correctly.

---

## Inbox Triage Options

For each captured item, Claude suggests one of:

| Option | Destination | When Appropriate |
|--------|-------------|------------------|
| File to Project | `3_Projects/{name}/` | Clearly related to active project |
| File to Area | `4_Areas/` | Ongoing responsibility, not project-specific |
| Fleeting note | `1_Fleeting/` | Interesting but needs more thought |
| Resource | `5_Resources/` | Reference material to keep |
| Extract task | Linear (Totoro) | Actionable item requiring time/energy |
| Extract reminder | Apple Reminders | Quick trigger item |
| Discard | Delete | Trivial, outdated, or duplicate |
| Skip | Stays in inbox | Decide later |

---

## Open Loop Detection

Claude identifies open loops by comparing:
- Morning brief priorities
- Tasks that were due today
- Explicit commitments made in captures

For each:
1. Check if it appears completed (Linear status, mentioned in captures)
2. If not, prompt user for status
3. Record outcome

---

## Template

The evening review behavior is defined in `9_Meta/prompts/evening-review.md`:

```markdown
---
name: evening-review
mode: interactive
triggers:
  - /review
  - /evening
  - /pm
---

## Purpose
Reflect on the day, process remaining inbox items, close open loops,
and prepare for tomorrow.

## Flow
1. Day summary
2. Inbox triage (one item at a time)
3. Open loops from morning brief
4. Tomorrow preview
5. Close out

## Behavior
- Conversational, one item at a time
- Don't rush; wait for responses
- Summarize decisions at the end
- Update daily note with review section
```

---

## Validation

| Check | Expected |
|-------|----------|
| All inbox items presented | ✓ |
| User decision required for each | ✓ |
| Open loops from brief surfaced | ✓ |
| Daily note updated with review | ✓ |
| Flags set correctly | ✓ |
| Archive triggered when appropriate | ✓ |

---

## Related Features

- **F3 (Daily Note)**: Review written here, flags set
- **F5 (Morning Brief)**: Open loops referenced
- **F8 (Inbox Processing)**: Same triage logic
- **F9 (Task Management)**: Tasks extracted to Linear
- **F15 (People)**: `last_contact` updated
