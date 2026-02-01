# F14: Bootstrap Process

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F14 |
| Priority | Phase 1 (Foundation) |
| Dependencies | None |
| Dependents | All features (bootstrap initializes the system) |

## Purpose

First-run setup that collects user profile, connects external sources, scaffolds the vault structure, and verifies everything works. Bootstrap can also reconfigure an existing installation.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F14.1 | Detect state: no vault, vault no config, vault with config | Must |
| F14.2 | Collect user profile: name, email, timezone | Must |
| F14.3 | Configure and test each external source | Must |
| F14.4 | Create folder structure if missing | Must |
| F14.5 | Write config.yaml and copy templates | Must |
| F14.6 | Create today's daily note | Must |
| F14.7 | Verify all connections | Must |
| F14.8 | Optional: seed existing data | Should |
| F14.9 | `claude bootstrap --reset` for full reconfiguration | Must |

---

## Detection States

| State | Condition | Action |
|-------|-----------|--------|
| No vault | Path doesn't exist | Full setup |
| Vault, no config | Path exists, no config.yaml | Config setup |
| Vault, config exists | Path exists, config.yaml exists | Verify & reconnect |

---

## Bootstrap Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      1. DETECT STATE                            │
│  Check for vault path and config.yaml                           │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                     2. USER PROFILE                             │
│  Collect name, email, timezone                                  │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                  3. SOURCE CONFIGURATION                        │
│  For each source: authenticate, configure, test                 │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   4. VAULT SCAFFOLDING                          │
│  Create folders, write config, copy templates                   │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                      5. VERIFICATION                            │
│  Test each component, run minimal brief                         │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    6. SEED DATA (Optional)                      │
│  Import existing notes, pull current tasks                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Interactive Session

### Startup

```
$ claude

Welcome to Digital Cortex.

Checking setup...
  Vault path: ~/Obsidian/Vault
  Status: No configuration found

Let's set up your system. This will take a few minutes.

Press Enter to continue or Ctrl+C to cancel.
```

### User Profile

```
USER PROFILE

What's your name?
> Paolo

What's your email?
> paolo@automattic.com

What timezone are you in?
  Detected: Europe/Vienna
  
Is this correct? [Y/n]
> Y

Profile saved:
  Name: Paolo
  Email: paolo@automattic.com
  Timezone: Europe/Vienna
```

### Source Configuration

```
SOURCE CONFIGURATION

Let's connect your services. You can skip any service.

─────────────────────────────────────────────────────────
GMAIL
─────────────────────────────────────────────────────────

Connect Gmail for email integration?
This allows reading unread/starred emails for morning briefs.

[c] Connect
[s] Skip

> c

Opening browser for Google authentication...
[Browser opens OAuth flow]

✓ Connected as paolo@automattic.com

Email categories to exclude from briefs:
  [x] Promotions
  [x] Updates
  [ ] Social
  [ ] Forums
  
Press Enter to confirm or edit selection.
> 

Gmail configured ✓
```

```
─────────────────────────────────────────────────────────
GOOGLE CALENDAR
─────────────────────────────────────────────────────────

Connect Google Calendar?
This allows reading events for scheduling suggestions.

[c] Connect (uses same Google account)
[s] Skip

> c

Using existing Google authentication...

Found 3 calendars:
  [x] paolo@automattic.com (primary)
  [x] Team Calendar
  [ ] Holidays

Include all selected calendars? [Y/n]
> Y

Calendar configured ✓
```

```
─────────────────────────────────────────────────────────
SLACK (via context-a8c MCP)
─────────────────────────────────────────────────────────

Connect Slack?
This allows reading your messages and mentions.

[c] Connect
[s] Skip

> c

Testing MCP connection...
✓ context-a8c MCP responding

Slack configured ✓
```

```
─────────────────────────────────────────────────────────
P2 (via context-a8c MCP)
─────────────────────────────────────────────────────────

Connect P2?
This allows reading your posts, comments, and mentions.

[c] Connect
[s] Skip

> c

Testing MCP connection...
✓ context-a8c MCP responding

P2 configured ✓
```

```
─────────────────────────────────────────────────────────
LINEAR
─────────────────────────────────────────────────────────

Connect Linear?
This allows reading assigned tasks and creating personal tasks.

[c] Connect
[s] Skip

> c

Opening browser for Linear authentication...
[Browser opens OAuth flow]

✓ Connected

Found teams:
  • Domain
  • Jetpack
  • Totoro

Which team is your personal task list?
> Totoro

Linear configured ✓
  Read: All teams (assigned to you)
  Write: Totoro only
```

```
─────────────────────────────────────────────────────────
APPLE REMINDERS
─────────────────────────────────────────────────────────

Connect Apple Reminders?
This allows creating reminders and shopping list items.

[c] Connect
[s] Skip

> c

Testing access...
✓ Reminders accessible via osascript

Found lists:
  [x] Reminders
  [x] Shopping
  [ ] Work
  [ ] Personal

Select lists to use (Reminders + Shopping recommended):
> 

Apple Reminders configured ✓
```

### Vault Scaffolding

```
VAULT SCAFFOLDING

Creating folder structure...

~/Obsidian/Vault/
  ├── .claude/              ✓ created
  ├── 0_Inbox/              ✓ created
  ├── 1_Fleeting/           ✓ created
  ├── 2_Drafts/             ✓ created
  ├── 3_Projects/           ✓ created
  ├── 4_Areas/              ✓ created
  ├── 5_Resources/          ✓ created
  ├── 6_Archive/
  │   └── Daily-Notes/      ✓ created
  ├── 7_Assets/             ✓ created
  ├── 8_People/             ✓ created
  └── 9_Meta/
      ├── prompts/          ✓ created
      ├── config.yaml       ✓ written
      ├── memory.md         ✓ created
      ├── state.json        ✓ created
      └── pending.json      ✓ created

Copying templates...
  morning-brief.md          ✓
  evening-review.md         ✓
  weekly-review.md          ✓
  process-inbox.md          ✓

Creating today's daily note...
  0_Inbox/2025-01-31 Friday.md ✓

Vault scaffolding complete.
```

### Verification

```
VERIFICATION

Testing all connections...

  Gmail           ✓ 12 unread emails
  Calendar        ✓ 3 events today
  Slack           ✓ MCP responding
  P2              ✓ MCP responding
  Linear          ✓ 9 tasks assigned
  Reminders       ✓ 2 reminders due

All systems operational ✓
```

### Seed Data (Optional)

```
SEED DATA

Would you like to import existing data?

Import existing Obsidian notes from another vault?
  This will copy and organize notes into the new structure.
  [y/N] n

Pull calendar events from the past week?
  This adds context for weekly review.
  [y/N] n

Pull open Linear issues?
  This ensures your brief includes all current tasks.
  [Y/n] y

Pulling Linear issues...
  ✓ 9 issues retrieved
  
  Summary:
    Domain team: 3 issues
    Jetpack team: 1 issue
    Totoro: 5 issues
```

### Complete

```
─────────────────────────────────────────────────────────

SETUP COMPLETE

Digital Cortex is ready.

Your vault is at: ~/Obsidian/Vault
Configuration: ~/Obsidian/Vault/9_Meta/config.yaml

Quick start:
  • Run /brief for your first morning brief
  • Run /help to see all commands
  • Edit config.yaml to customize behavior

Welcome aboard, Paolo.
```

---

## Reset Mode

```
$ claude bootstrap --reset

WARNING: This will reconfigure Digital Cortex.

Current configuration will be backed up to:
  9_Meta/config.yaml.bak

Vault structure and notes will NOT be deleted.

Continue? [y/N] y

Backing up configuration...
Starting fresh setup...

[Normal bootstrap flow continues]
```

---

## Partial Reconfiguration

```
$ claude auth linear

Re-authenticating Linear...

Opening browser for Linear authentication...
[Browser opens OAuth flow]

✓ Connected

Testing connection...
  ✓ 9 tasks retrieved

Linear re-authenticated successfully.
```

---

## Bootstrap Checks

### Pre-flight

| Check | Action if Failed |
|-------|------------------|
| Vault path writable | Error: choose different path |
| Disk space available | Warning: proceed with caution |
| Internet connected | Warning: source setup will fail |
| Required tools installed | Error: list missing tools |

### Post-flight

| Check | Action if Failed |
|-------|------------------|
| Config valid | Error: show validation issues |
| Folders exist | Error: retry creation |
| Sources connected | Warning: can configure later |
| Daily note created | Error: check permissions |

---

## Configuration Output

The resulting `config.yaml`:

```yaml
# Digital Cortex Configuration
# Generated: 2025-01-31T10:00:00+01:00

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
    personal_team_id: "team-abc123"
  
  reminders:
    enabled: true
    lists:
      - Reminders
      - Shopping

vault:
  path: ~/Obsidian/Vault
  daily_note_format: "YYYY-MM-DD dddd"
  archive_path: "6_Archive/Daily-Notes"
  stale_threshold_hours: 4

behavior:
  brief_mode: suggestion
  review_mode: interactive
  auto_retry_minutes: 5
  max_retries: 5
```

---

## Validation

| Check | Expected |
|-------|----------|
| Detects vault state correctly | ✓ |
| Collects all profile info | ✓ |
| Each source configurable | ✓ |
| Skip option works | ✓ |
| Folders created correctly | ✓ |
| Config file valid | ✓ |
| Templates copied | ✓ |
| Daily note created | ✓ |
| Verification passes | ✓ |
| --reset backs up config | ✓ |

---

## Related Features

- **F1 (Vault Structure)**: Defines what to create
- **F10 (External Sources)**: Configures connections
- **F13 (Templates)**: Files to copy
