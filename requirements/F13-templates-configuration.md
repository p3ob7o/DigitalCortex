# F13: Templates & Configuration

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F13 |
| Priority | Phase 1 (Foundation) |
| Dependencies | F1 (Vault Structure) |
| Dependents | F5, F6, F7, F8 (all rituals use templates) |

## Purpose

Provide portable, editable prompt templates and user configuration. The system should work for any user by editing configuration files, not code. Users can customize behavior by modifying templates directly.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F13.1 | Templates live in 9_Meta/prompts/ | Must |
| F13.2 | Templates use `{{variable}}` syntax | Must |
| F13.3 | Variables resolved from config.yaml | Must |
| F13.4 | User can edit templates to customize | Must |
| F13.5 | Config includes user profile, sources, vault settings | Must |
| F13.6 | Invalid config shows clear error messages | Must |

---

## File Structure

```
9_Meta/
├── config.yaml              ← User configuration
├── prompts/
│   ├── morning-brief.md     ← Morning brief template
│   ├── evening-review.md    ← Evening review template
│   ├── weekly-review.md     ← Weekly review template
│   └── process-inbox.md     ← Inbox processing template
├── memory.md                ← Claude's learned preferences
├── state.json               ← Sync state, timestamps
└── pending.json             ← Queued operations
```

---

## Configuration File

### `9_Meta/config.yaml`

```yaml
# Digital Cortex Configuration

user:
  name: Paolo
  email: paolo@automattic.com
  timezone: Europe/Vienna

sources:
  gmail:
    enabled: true
    exclude_categories:
      - PROMOTIONS
      - UPDATES
  
  calendar:
    enabled: true
    calendars: all
  
  slack:
    enabled: true
    mcp: context-a8c
  
  p2:
    enabled: true
    mcp: context-a8c
  
  linear:
    enabled: true
    personal_team: Totoro
    personal_team_id: "team-uuid-here"
  
  reminders:
    enabled: true
    lists:
      - Reminders
      - Shopping

vault:
  daily_note_format: "YYYY-MM-DD dddd"
  archive_path: "6_Archive/Daily-Notes"
  stale_threshold_hours: 4

behavior:
  brief_mode: suggestion      # suggestion | autonomous
  review_mode: interactive    # interactive | suggestion
  auto_retry_minutes: 5
  max_retries: 5
```

---

## Template Format

Templates are Markdown files with YAML frontmatter:

```markdown
---
name: morning-brief
mode: suggestion
triggers:
  - /brief
  - /morning
  - /am
---

## Purpose
Prepare {{user.name}} for the day by synthesizing external inputs and 
yesterday's captures into an actionable brief.

## Sources
Pull from (since last brief):
- Gmail: unread and starred emails (full content)
- Calendar: today's events
- Slack: messages by me, mentions of me + surrounding context
...

## Output Structure
Write to today's daily note at top:

### Morning Brief — {{date.weekday}}, {{date.month}} {{date.day}}
...

## Behavior
- Present brief in terminal for review
- Wait for approval/modifications on each suggestion
- Do not auto-file or auto-create without confirmation
```

---

## Variable Syntax

### Basic Variables

```
{{user.name}}           → Paolo
{{user.email}}          → paolo@automattic.com
{{user.timezone}}       → Europe/Vienna
```

### Date Variables

```
{{date.today}}          → 2025-01-31
{{date.weekday}}        → Friday
{{date.month}}          → January
{{date.day}}            → 31
{{date.year}}           → 2025
{{date.iso}}            → 2025-01-31T00:00:00+01:00
```

### Source Variables

```
{{sources.linear.personal_team}}    → Totoro
{{sources.reminders.lists}}         → ["Reminders", "Shopping"]
```

### Computed Variables

```
{{last_brief}}          → 2025-01-30T07:30:00+01:00
{{days_since_review}}   → 1
```

---

## Template Files

### `morning-brief.md`

See F5 (Morning Brief) for full content.

Key sections:
- Purpose
- Sources (what to pull)
- Output Structure (how to format)
- Behavior (interaction mode)

### `evening-review.md`

See F6 (Evening Review) for full content.

Key sections:
- Purpose
- Flow (step-by-step process)
- Triage Options
- Behavior

### `weekly-review.md`

See F7 (Weekly Review) for full content.

Key sections:
- Purpose
- Sources
- Flow
- Behavior

### `process-inbox.md`

See F8 (Inbox Processing) for full content.

Key sections:
- Purpose
- Scope
- Triage Options
- Behavior

---

## Memory File

`9_Meta/memory.md` stores Claude's learned preferences:

```markdown
# Claude Memory

## User Preferences
- Prefers brief summaries over detailed explanations
- Usually processes inbox in evening, rarely mid-day
- Dislikes being asked too many questions

## Patterns Observed
- Most productive deep work: 09:00–12:00
- Typically skips Friday evening reviews
- Often captures voice memos while commuting

## Project Context
- Domain Bundling: High priority, frequent updates
- BI Phase 1: Waiting on external feedback since Jan 20

## People Notes
- Jane (Verisign): Prefers email over Slack
- Team standup: Usually runs 5 min over

Last updated: 2025-01-31
```

This file is readable and editable. Claude references it for personalization.

---

## State File

`9_Meta/state.json` tracks operational state:

```json
{
  "last_sync": {
    "gmail": "2025-01-31T07:00:00Z",
    "calendar": "2025-01-31T07:00:00Z",
    "slack": "2025-01-31T07:00:00Z",
    "p2": "2025-01-31T07:00:00Z",
    "linear": "2025-01-31T07:00:00Z",
    "reminders": "2025-01-31T07:00:00Z"
  },
  "last_brief": "2025-01-31T07:30:00Z",
  "last_review": "2025-01-30T21:00:00Z",
  "last_weekly": "2025-01-26T14:00:00Z",
  "weekly_intentions": [
    "Finalize domain-bundling API spec",
    "Prepare Q1 planning presentation"
  ]
}
```

---

## Configuration Validation

On startup, Claude validates config:

```
Loading configuration...

Validating config.yaml:
  ✓ user.name present
  ✓ user.email valid format
  ✓ user.timezone valid
  ✓ sources.gmail.enabled is boolean
  ✓ sources.linear.personal_team present
  ✓ vault.daily_note_format valid
  
Configuration valid.
```

### Error Examples

```
ERROR: config.yaml validation failed

  Line 15: sources.linear.personal_team
    Expected: string
    Found: (missing)
    
  This field is required for task creation.
  
Fix the configuration and try again.
```

---

## Customization Examples

### Change Brief Time Preferences

Edit `morning-brief.md`:

```markdown
## Time Preferences
- Don't suggest tasks before 09:00
- Prefer 90-minute focus blocks
- Keep buffer between meetings (30 min)
```

### Add Custom Source

Edit `config.yaml`:

```yaml
sources:
  notion:
    enabled: true
    api_key: "{{env.NOTION_API_KEY}}"
    database_id: "abc123"
```

Then update templates to reference the new source.

### Disable a Ritual

Edit `config.yaml`:

```yaml
behavior:
  weekly_review_enabled: false
```

---

## Template Inheritance (Future)

Templates could support inheritance:

```markdown
---
extends: base-review
name: evening-review
---

## Additional Steps
[Evening-specific content]
```

Not implemented in v1, but structure supports it.

---

## Validation

| Check | Expected |
|-------|----------|
| config.yaml parses correctly | ✓ |
| All required fields present | ✓ |
| Variables resolve correctly | ✓ |
| Templates load without error | ✓ |
| Invalid config shows clear error | ✓ |
| Memory file editable | ✓ |

---

## Related Features

- **F1 (Vault Structure)**: Defines where config lives
- **F5-F8 (Rituals)**: Consume templates
- **F14 (Bootstrap)**: Creates initial config
