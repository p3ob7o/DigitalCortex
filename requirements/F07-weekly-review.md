# F7: Weekly Review

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F7 |
| Priority | Phase 3 (Rituals) |
| Dependencies | F1, F3, F4, F6, F10 |
| Dependents | None |

## Purpose

Step back from daily execution to review the week as a whole, check project health, triage aging fleeting notes, and prepare for the week ahead. This is a higher-altitude review than daily rituals.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F7.1 | Triggers: `claude weekly`, `/weekly`, `/week`, natural language | Must |
| F7.2 | Mode: Interactive | Must |
| F7.3 | Typical cadence: Sunday | Should |
| F7.4 | Review archived daily notes from past week | Must |
| F7.5 | Check status of all active projects | Must |
| F7.6 | Triage fleeting notes older than 7 days | Must |
| F7.7 | Preview calendar for upcoming week | Must |
| F7.8 | Capture themes/intentions for the week | Should |

---

## Sources

| Source | Data | Purpose |
|--------|------|---------|
| Archived daily notes | Past 7 days | Week in review |
| Calendar | Past week + upcoming week | What happened, what's coming |
| Linear | Completed tasks, open tasks | Accomplishments, load |
| `1_Fleeting/` | Notes older than 7 days | Triage aging items |
| `3_Projects/` | All projects | Status check |

---

## Review Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  1. WEEK IN REVIEW                          │
│  Highlights, completions, patterns                          │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  2. PROJECTS STATUS                         │
│  For each active project: still accurate?                   │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               3. FLEETING NOTES TRIAGE                      │
│  Notes >7 days old need a decision                          │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                 4. CALENDAR PREVIEW                         │
│  Upcoming week: busy days, prep needed                      │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              5. THEMES & INTENTIONS                         │
│  Focus areas for the coming week                            │
└─────────────────────────────────────────────────────────────┘
```

---

## Interactive Session

### 1. Week in Review

```
Good afternoon, {{user.name}}. Let's review your week.

WEEK OF JANUARY 27 – FEBRUARY 2

Meetings: 8 total (down from 12 last week)
Tasks completed: 14
Tasks created: 9

HIGHLIGHTS FROM DAILY NOTES
• Monday: Kicked off domain-bundling project
• Wednesday: Shipped pricing doc to Legal
• Thursday: Good 1:1 with Jane, discussed Q1 targets
• Friday: Transfer time idea captured

TOP ACCOMPLISHMENTS
• Domain bundling pricing approved
• BI Phase 1 mockups reviewed
• 3 P2 posts published

Any reflections on the week?
```

---

### 2. Projects Status

```
Let's check on your active projects.

PROJECT 1 of 4: Domain Bundling
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status: in-progress
Last activity: Friday (pricing doc)
Next action: "Finalize API spec"
Due: February 15

Is this still accurate?
  [y] Yes, continue
  [u] Update status
  [n] Update next action
  [p] Mark as paused
  [c] Mark as completed

Your choice: _
```

Repeat for each active project.

---

### 3. Fleeting Notes Triage

```
FLEETING NOTES OLDER THAN 7 DAYS

You have 3 notes that need decisions.

NOTE 1 of 3: thought-on-transfer-pricing.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Created: January 23 (9 days ago)
Content: "What if we showed transfer progress as a 
         timeline rather than percentage? More intuitive
         for non-technical users..."

Options:
  [d] Develop into draft
  [p] File to project: domain-bundling
  [r] Move to resources
  [a] Archive (not pursuing)
  [k] Keep in fleeting (needs more time)

Your choice: _
```

---

### 4. Calendar Preview

```
NEXT WEEK: February 3–9

Monday
  • 10:00 Team standup
  • 14:00 Q1 Planning kickoff (2h)

Tuesday
  • 09:00 Design review
  • 15:00 External call with Verisign

Wednesday
  • Light day — good for deep work

Thursday
  • 10:00 Team standup
  • All-day offsite prep

Friday
  • 🏢 Office day
  • 11:00 All-hands

OBSERVATIONS
• Tuesday is meeting-heavy
• Wednesday is your best deep work day
• Thursday needs offsite prep — block time?

Any prep you need to do this week?
```

---

### 5. Themes & Intentions

```
FOCUS FOR THE WEEK

What would you like to focus on this week?
(These will appear in Monday's morning brief)

Examples from your active work:
  • Finalize domain-bundling API spec
  • Prepare for Q1 planning kickoff
  • Clear fleeting notes backlog

Enter your intentions (or [s]kip): _
```

---

## Output Artifacts

### Weekly Review Note (Optional)

If the user wants to capture the review:

```markdown
# Weekly Review — Week of January 27

## Accomplishments
- Domain bundling pricing approved
- BI Phase 1 mockups reviewed
- 3 P2 posts published

## Project Updates
- **Domain Bundling**: On track, API spec next
- **BI Phase 1**: Paused pending feedback

## Fleeting Notes Processed
- 2 filed to projects
- 1 archived

## Intentions for Next Week
- Finalize domain-bundling API spec
- Prepare Q1 planning presentation
- Block Wednesday for deep work
```

### Daily Note Integration

Monday's morning brief includes:

```markdown
### Weekly Intentions
From your Sunday review:
- Finalize domain-bundling API spec
- Prepare Q1 planning presentation
- Block Wednesday for deep work
```

---

## Project Status Options

| Option | Action |
|--------|--------|
| Continue | No change |
| Update status | Change to: backlog, in-progress, paused, completed, canceled |
| Update next action | Edit the `next_action` field |
| Mark paused | Set status=paused, prompt for reason |
| Mark completed | Set status=completed, offer to archive |

---

## Fleeting Note Triage Options

| Option | Destination | When Appropriate |
|--------|-------------|------------------|
| Develop into draft | `2_Drafts/` | Ready to write about |
| File to project | `3_Projects/{name}/` | Belongs to active project |
| Move to resources | `5_Resources/` | Reference material |
| Archive | `6_Archive/` | Not pursuing but worth keeping |
| Delete | Remove | Not valuable |
| Keep in fleeting | `1_Fleeting/` | Needs more time (max 2 more weeks) |

---

## Template

The weekly review behavior is defined in `9_Meta/prompts/weekly-review.md`:

```markdown
---
name: weekly-review
mode: interactive
triggers:
  - /weekly
  - /week
---

## Purpose
Step back from daily execution to review the week, maintain the system,
and prepare for the week ahead.

## Flow
1. Week in review (highlights, patterns)
2. Projects status (each active project)
3. Fleeting notes triage (older than 7 days)
4. Calendar preview (upcoming week)
5. Themes and intentions

## Behavior
- Allow time for reflection
- This is higher-altitude than daily reviews
- Capture insights if user wants
- Surface intentions in Monday's brief
```

---

## Validation

| Check | Expected |
|-------|----------|
| Past week's daily notes reviewed | ✓ |
| All active projects checked | ✓ |
| All aging fleeting notes triaged | ✓ |
| Calendar preview shown | ✓ |
| Intentions captured (if provided) | ✓ |

---

## Related Features

- **F3 (Daily Note)**: Reviews archived notes
- **F4 (Frontmatter)**: Updates project status
- **F5 (Morning Brief)**: Surfaces weekly intentions
- **F10 (Sources)**: Calendar data
