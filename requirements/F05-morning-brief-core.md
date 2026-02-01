# F05: Morning Brief — Core

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F05 |
| Priority | Phase 3 (Rituals) |
| Dependencies | F1, F3, F4 |
| Dependents | F06 (Evening Review references brief) |
| Sub-features | F05.1–F05.6 (source integrations) |

## Purpose

Prepare the user for the day by pulling information from external sources, combining with yesterday's captures, and synthesizing into actionable priorities with suggested time slots. This document covers orchestration, output structure, and interaction mode. Individual source integrations are defined in F05.1–F05.6.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F05.1 | Triggers: `claude brief`, `/brief`, `/morning`, `/am`, natural language | Must |
| F05.2 | Mode: Suggestion (Claude prepares, user approves) | Must |
| F05.3 | Output written to top of today's daily note | Must |
| F05.4 | Presented interactively in terminal for review | Must |
| F05.5 | User can approve, modify, or reject suggestions | Must |
| F05.6 | Each suggestion includes rationale | Must |
| F05.7 | Graceful degradation when sources unavailable | Must |
| F05.8 | Sources pulled in parallel where possible | Should |

---

## Source Overview

The morning brief pulls from these sources (each defined in its own PRD):

| Source | PRD | Data |
|--------|-----|------|
| Gmail | F05.1 | Unread + starred emails |
| Calendar | F05.2 | Today's events |
| Slack | F05.3 | Messages, mentions |
| P2 | F05.4 | Posts, comments, mentions |
| Linear | F05.5 | Assigned tasks, completed |
| Reminders | F05.6 | Due today, overdue, upcoming |

Additionally, the brief references local inbox items (yesterday's daily note, unprocessed captures).

---

## Orchestration Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      1. TRIGGER                                 │
│  User invokes /brief or natural language                        │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   2. PARALLEL FETCH                             │
│  Pull from all enabled sources simultaneously                   │
│  Track failures, use stale data if available                    │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    3. SYNTHESIZE                                │
│  Combine source data into unified structure                     │
│  Identify priorities, conflicts, decisions needed               │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                 4. INTERACTIVE REVIEW                           │
│  Present each section for approval/modification                 │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                     5. WRITE                                    │
│  Write final brief to daily note                                │
│  Update sync timestamps                                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Output Structure

The morning brief is written to the daily note with this structure:

```markdown
## Morning Brief — Friday, January 31

### Calendar
[From F05.2]

### Completed Since Yesterday
[From F05.5 - Linear]

### Emails Requiring Attention
[From F05.1 - Gmail]

### Slack & P2
[From F05.3 and F05.4]

### Tasks & Reminders
[From F05.5 - Linear and F05.6 - Reminders]

### Suggested Priorities
[Synthesized from all sources]

### Decisions Needed
[Items requiring user input for filing/extraction]
```

---

## Suggested Priorities Section

Claude synthesizes a prioritized list based on:

1. **Urgency signals** — Due dates, "ASAP", "EOD", explicit deadlines
2. **Importance signals** — Blocking others, from leadership, high-priority labels
3. **Calendar awareness** — What can fit before meetings
4. **Dependencies** — What unblocks other work

Each priority includes:
- What to do
- Why it matters (rationale)
- Suggested time slot

```markdown
### Suggested Priorities

1. **Respond to Legal on pricing** — blocking domain-bundling launch
   → Suggested slot: 08:30–09:30 (before standup)
   
2. **Address Slack thread on Q1 targets** — team waiting for input
   → Suggested slot: 09:30–10:00
   
3. **Send revised pricing doc** — due today
   → Suggested slot: 11:00–12:00 (deep work block)
```

---

## Time Slot Suggestions

Claude considers:

| Factor | How Used |
|--------|----------|
| Calendar events | Blocked time unavailable |
| Meeting buffers | 15 min before/after meetings |
| Task duration | Estimated from complexity |
| User patterns | From memory (morning person, etc.) |
| Open blocks | Identified and allocated |

```
Open blocks identified:
  08:00–10:00 (2h before standup)
  11:00–14:00 (3h between meetings)
  15:00–18:00 (3h afternoon)

Suggested allocation:
  08:30–09:30 → Legal response (needs focus)
  09:30–10:00 → Slack catch-up (quick)
  11:00–12:30 → Pricing doc (deep work)
```

---

## Decisions Needed Section

Items that require user input before proceeding:

```markdown
### Decisions Needed

- [ ] File [[slack-thread-verisign.md]] → Projects/domain-bundling?
      (Mentions Q1 targets, references pricing analysis)
      
- [ ] Extract task from Legal email: "Review and sign off by EOD"?

- [ ] Voice memo from yesterday mentions transfer flow idea — create Fleeting note?
```

These are presented interactively for resolution.

---

## Interactive Review Flow

```
Good morning, Paolo. Here's your brief for Friday, January 31.

CALENDAR
You have 2 meetings today:
  • 10:00 Weekly standup (Domain team)
  • 14:00 1:1 with Jane Smith

PRIORITIES
I suggest focusing on these today:

1. Respond to Legal on pricing
   This is blocking the domain-bundling launch.
   → Suggested: 08:30–09:30 (before standup)
   
   [a]ccept / [m]odify / [s]kip? _
```

### Response Handling

| Response | Action |
|----------|--------|
| Accept (a) | Record suggestion as-is |
| Modify (m) | Prompt for changes |
| Skip (s) | Omit from final brief |

At the end:
1. Write final brief to daily note
2. Summarize decisions made
3. Offer to block calendar time

---

## Suggestion Mode Behavior

The morning brief operates in **suggestion mode**:

- Claude prepares everything
- User reviews and approves
- No automatic actions without confirmation

This contrasts with autonomous mode (not used for briefs) where Claude would act without confirmation.

---

## Graceful Degradation

When sources fail, the brief continues with available data:

```
Preparing your brief...

  Gmail         ✓ 12 unread
  Calendar      ✓ 3 events today
  Slack         ⚠ Unavailable (MCP timeout)
  P2            ✓ 2 mentions
  Linear        ✓ 5 tasks
  Reminders     ✓ 2 due today

⚠ Slack data unavailable. Continuing without it.
  Check Slack manually or run /sync later.
```

See F12 (Error Handling) for full degradation behavior.

---

## Template

The morning brief behavior is defined in `9_Meta/prompts/morning-brief.md`:

```markdown
---
name: morning-brief
mode: suggestion
triggers:
  - /brief
  - /morning
  - /am
sources:
  - gmail
  - calendar
  - slack
  - p2
  - linear
  - reminders
---

## Purpose
Prepare {{user.name}} for the day by synthesizing external inputs and 
yesterday's captures into an actionable brief.

## Output Structure
[Format specification]

## Behavior
- Present brief in terminal for review
- Wait for approval/modifications on each suggestion
- Do not auto-file or auto-create without confirmation
```

---

## Validation

| Check | Expected |
|-------|----------|
| All enabled sources attempted | ✓ |
| Unavailable sources show warning | ✓ |
| Brief written to daily note | ✓ |
| Interactive review completes | ✓ |
| Suggestions include rationale | ✓ |
| Time slots consider calendar | ✓ |

---

## Related Features

- **F05.1–F05.6**: Source-specific integrations
- **F03 (Daily Note)**: Brief written here
- **F06 (Evening Review)**: References morning brief items
- **F12 (Error Handling)**: Graceful degradation
- **F13 (Templates)**: Defines brief behavior
