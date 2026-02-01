# F9: Task Management

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F9 |
| Priority | Phase 4 (Integration) |
| Dependencies | F1, F4, F10 (Linear + Reminders) |
| Dependents | F5 (Brief), F6 (Review), F8 (Processing) |

## Purpose

Manage actionable items by separating tasks (require time and mental energy) from reminders (quick triggers). Tasks live in Linear, reminders in Apple Reminders. Claude bridges both systems.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F9.1 | Tasks live in Linear | Must |
| F9.2 | Claude reads tasks assigned to user from all teams | Must |
| F9.3 | Claude creates/edits tasks only in Totoro team | Must |
| F9.4 | Reminders live in Apple Reminders | Must |
| F9.5 | Two reminder lists: Reminders, Shopping | Must |
| F9.6 | Claude creates reminders in appropriate list | Must |
| F9.7 | Linear projects map to Obsidian projects | Must |
| F9.8 | Linear labels map to Obsidian areas | Must |

---

## Task vs. Reminder Classification

| Type | Characteristics | Examples | Destination |
|------|-----------------|----------|-------------|
| **Task** | Requires dedicated time, mental energy, measurable completion | "Write pricing analysis", "Review mockups", "Prepare presentation" | Linear (Totoro) |
| **Reminder** | Quick, triggered by time/location, minimal cognitive load | "Call Jane", "Take medication", "Check on deployment" | Apple Reminders |
| **Shopping** | Item to purchase | "Buy milk", "Order cables" | Apple Reminders (Shopping) |

### Classification Heuristic

```
if item.matches("buy", "order", "get", "pick up") AND item.is_short:
    → Shopping list
elif item.requires_time_block OR item.is_complex:
    → Linear task
else:
    → Reminder
```

---

## Linear Integration

### Read Access (All Teams)

Claude reads issues assigned to the user across all Linear teams to provide a complete picture in briefs and reviews.

```
Reading from Linear:
  • Domain team: 3 issues assigned
  • Jetpack team: 1 issue assigned
  • Totoro (personal): 5 issues
  Total: 9 issues to surface in brief
```

### Write Access (Totoro Only)

Claude can only create or modify issues in the designated personal team (Totoro). This prevents accidental changes to shared team backlogs.

```
Creating task in Linear:
  Team: Totoro ✓
  Title: "Update pricing documentation"
  Project: domain-bundling
  Due: 2025-02-14
```

### Mapping to Obsidian

| Linear Entity | Obsidian Entity | Sync |
|---------------|-----------------|------|
| Project | `3_Projects/{name}/` folder | Manual reference via `linear_project` |
| Label | `4_Areas/{name}.md` file | Manual reference via `linear_label` |
| Status | `status` frontmatter | One-way (Linear → Obsidian) |

---

## Apple Reminders Integration

### Lists

| List | Purpose | Examples |
|------|---------|----------|
| Reminders | General quick items | "Call dentist", "Check deployment" |
| Shopping | Items to purchase | "Buy milk", "Order HDMI cable" |

### Access

Claude accesses Apple Reminders via CLI or osascript:

```bash
# Read reminders
osascript -e 'tell application "Reminders" to get reminders of list "Reminders"'

# Create reminder
osascript -e 'tell application "Reminders" to make new reminder in list "Reminders" with properties {name:"Call dentist", due date:date "2025-02-01 10:00:00"}'
```

---

## Commands

### Create Task

```
/task Update pricing documentation by Feb 14

Creating in Linear (Totoro):
  Title: Update pricing documentation
  Due: 2025-02-14
  Project: (none — add one?)
  
  [c] Create as-is
  [p] Add to project
  [e] Edit details
```

### Create Reminder

```
/reminder Call dentist tomorrow at 10am

Creating in Apple Reminders:
  List: Reminders
  Title: Call dentist
  Due: 2025-02-01 10:00
  
  [c] Create
  [e] Edit
```

### Add to Shopping

```
/shopping milk, bread, eggs

Adding to Shopping list:
  • Milk
  • Bread
  • Eggs
  
  [c] Create all
  [e] Edit
```

---

## Task Extraction During Processing

When processing inbox items, Claude identifies actionable content:

```
ITEM: Email from Legal

Content:
  "Please review and sign off on the revised pricing 
   terms by end of day Friday."

Detected action: "Review and sign off on pricing terms"

This looks like a task (requires dedicated time).

Create in Linear?
  Title: Review and sign off on pricing terms
  Due: 2025-01-31 (Friday EOD)
  Project: domain-bundling
  
  [y] Yes, create task
  [r] Create as reminder instead
  [n] No, just file the email
```

---

## Brief Integration

Morning briefs aggregate tasks from all sources:

```markdown
### Tasks & Reminders

**Due Today**
- [ ] Review pricing terms (Linear: DOMAIN-456)
- [ ] Send weekly report (Linear: TOTORO-12)

**Due This Week**
- [ ] Prepare Q1 deck (Linear: TOTORO-15) — Monday
- [ ] API spec review (Linear: DOMAIN-789) — Wednesday

**Reminders**
- Call dentist @ 10:00
- Check deployment status @ 14:00

**Shopping**
- Milk
- Bread
```

---

## Review Integration

Evening reviews check task completion:

```
TASK STATUS CHECK

These tasks were due today:

1. Review pricing terms (DOMAIN-456)
   Status in Linear: Done ✓

2. Send weekly report (TOTORO-12)
   Status in Linear: In Progress
   
   Did you complete this?
   [y] Yes, mark done
   [t] Carry to tomorrow
   [n] No, keep as-is
```

---

## Status Synchronization

| Direction | What | When |
|-----------|------|------|
| Linear → Brief | Task list, status, due dates | Morning brief, on-demand |
| Brief → Linear | Status updates (done/carry) | Evening review |
| Reminders → Brief | Due/overdue items | Morning brief |
| Brief → Reminders | Completion | When marked done |

Note: Obsidian project status is updated manually or during weekly review, not auto-synced from Linear.

---

## Error Handling

| Failure | Behavior |
|---------|----------|
| Linear unavailable | Queue task creation, warn in brief |
| Reminders CLI fails | Queue reminder, suggest manual creation |
| Task created in wrong team | Reject and prompt for correction |

See F12 (Error Handling) for details.

---

## Validation

| Check | Expected |
|-------|----------|
| Tasks read from all assigned teams | ✓ |
| Tasks created only in Totoro | ✓ |
| Reminders created in correct list | ✓ |
| Classification heuristic works | ✓ |
| Brief shows aggregated view | ✓ |
| Review updates statuses | ✓ |

---

## Related Features

- **F5 (Morning Brief)**: Displays tasks and reminders
- **F6 (Evening Review)**: Checks completion, carries forward
- **F8 (Inbox Processing)**: Extracts tasks from captures
- **F10 (External Sources)**: Linear and Reminders access
- **F12 (Error Handling)**: Queuing failed operations
