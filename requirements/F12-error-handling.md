# F12: Error Handling & Offline Mode

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F12 |
| Priority | Phase 5 (Polish) |
| Dependencies | F10 (Sources), F11 (Commands) |
| Dependents | All features that interact with external services |

## Purpose

Ensure the system works reliably even when sources fail or the user is offline. Failures should be transparent, recoverable, and never lose user data.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F12.1 | Partial source failure doesn't block operations | Must |
| F12.2 | Unavailable sources show inline warning | Must |
| F12.3 | Stale data (<4h) used with warning | Must |
| F12.4 | Failed writes queue for retry | Must |
| F12.5 | Queued writes auto-retry in background | Must |
| F12.6 | `/sync` forces refresh and processes queue | Must |
| F12.7 | `/status` shows health and pending ops | Must |
| F12.8 | Offline mode enables local operations | Must |

---

## Principles

1. **Partial success over total failure** — Continue with what works
2. **Transparency** — Always show what's missing or stale
3. **No data loss** — Queue failed writes, retry automatically
4. **Local-first** — Core operations work without network
5. **Graceful recovery** — System self-heals when connectivity returns

---

## Source Failure Handling

### During Briefs/Reviews

When a source is unavailable:

```
Good morning. Preparing your brief...

  Gmail         ✓ 12 unread
  Calendar      ✓ 3 events today
  Slack         ⚠ Unavailable (MCP timeout)
  P2            ✓ 2 mentions
  Linear        ✓ 5 tasks
  Reminders     ✓ 2 due today

⚠ Slack data unavailable. Continuing without it.
  Check Slack manually or run /sync later.

---

## Morning Brief — Friday, January 31

[Brief continues with available data]
```

### Stale Data

When data is older than the threshold:

```
Preparing brief...

  Gmail         ✓ synced 10 min ago
  Calendar      ✓ synced 10 min ago  
  Slack         ⚠ synced 3 hours ago (stale)
  P2            ⚠ synced 5 hours ago (stale)
  Linear        ✓ synced 10 min ago

⚠ Using cached Slack and P2 data. Run /sync for fresh data.
```

### Thresholds

| Freshness | Treatment |
|-----------|-----------|
| < 30 min | Fresh ✓ |
| 30 min – 4 hours | Usable, show "synced X ago" |
| > 4 hours | Stale ⚠, warn prominently |

---

## Write Failure Handling

### Queue Mechanism

Failed writes are stored in `9_Meta/pending.json`:

```json
{
  "pending": [
    {
      "id": "op-001",
      "operation": "create_task",
      "target": "linear",
      "payload": {
        "title": "Update pricing documentation",
        "team": "Totoro",
        "project": "domain-bundling"
      },
      "created_at": "2025-01-31T14:00:00Z",
      "failed_at": "2025-01-31T14:00:00Z",
      "retries": 2,
      "last_error": "API timeout"
    },
    {
      "id": "op-002",
      "operation": "create_reminder",
      "target": "reminders",
      "payload": {
        "list": "Reminders",
        "title": "Call dentist",
        "due": "2025-02-01T10:00:00"
      },
      "created_at": "2025-01-31T14:30:00Z",
      "failed_at": "2025-01-31T14:30:00Z",
      "retries": 1,
      "last_error": "osascript failed"
    }
  ]
}
```

### Retry Logic

| Attempt | Delay |
|---------|-------|
| 1 | Immediate |
| 2 | 5 minutes |
| 3 | 15 minutes |
| 4 | 1 hour |
| 5+ | Manual via /sync |

After 5 failed attempts, the operation stays queued but stops auto-retrying. User must run `/sync` or manually resolve.

### User Notification

When a write fails:

```
Creating task in Linear...

⚠ Failed to create task (API timeout)
  Queued for retry. Will attempt again in 5 minutes.
  
  The task details are saved locally.
  Run /status to see pending operations.
```

---

## `/status` Command

Shows system health and pending operations:

```
/status

DIGITAL CORTEX STATUS

Sources
  Gmail         ✓ synced 12 min ago
  Calendar      ✓ synced 12 min ago
  Slack         ⚠ synced 3 hours ago
  P2            ✓ synced 12 min ago
  Linear        ✗ authentication expired
  Reminders     ✓ synced 12 min ago

Pending Operations
  1. Create task "Update pricing docs" (Linear)
     Failed 2 times, last error: API timeout
     Next retry: 5 minutes
     
  2. Create reminder "Call dentist" (Reminders)
     Failed 1 time, last error: osascript failed
     Next retry: 15 minutes

Actions
  • Re-authenticate Linear: claude auth linear
  • Force retry all: /sync
  • Clear stuck operation: /clear-pending <id>
```

---

## `/sync` Command

Forces refresh and processes queue:

```
/sync

Syncing all sources...
  Gmail         ✓ refreshed
  Calendar      ✓ refreshed
  Slack         ✓ refreshed (was stale)
  P2            ✓ refreshed
  Linear        ✗ still failing (auth expired)
  Reminders     ✓ refreshed

Processing pending operations...
  1. Create task "Update pricing docs"
     ✗ Linear still unavailable, will retry later
     
  2. Create reminder "Call dentist"
     ✓ Created successfully

Summary: 5/6 sources synced, 1/2 pending operations completed
```

---

## Offline Mode

When no network is available:

### Detected Automatically

```
/brief

⚠ Offline detected. Running in local-only mode.

Available:
  • Inbox processing (local files)
  • Capture to daily note
  • Query local vault (projects, people)

Unavailable:
  • External source sync (Gmail, Slack, etc.)
  • Create tasks in Linear
  • Create reminders (may work via local osascript)

Operations requiring network will be queued.

Continue with local-only brief? [y/n]
```

### Operations by Mode

| Operation | Online | Offline |
|-----------|--------|---------|
| Morning brief (full) | ✓ | Partial (local only) |
| Evening review | ✓ | ✓ (local items) |
| Weekly review | ✓ | Partial |
| Inbox processing | ✓ | ✓ |
| Capture | ✓ | ✓ |
| Create task | ✓ | Queued |
| Create reminder | ✓ | May work locally |
| Query vault | ✓ | ✓ |
| Query tasks | ✓ | Cached only |

---

## Critical Failures

### Obsidian Vault Inaccessible

This is a critical failure—surface immediately:

```
CRITICAL: Cannot access vault at /Users/paolo/Obsidian/Vault

Possible causes:
  • Path doesn't exist
  • Permissions denied
  • Disk unmounted

Digital Cortex cannot operate without vault access.
Please check the path and try again.
```

### Configuration Corrupted

```
ERROR: config.yaml is invalid

Attempting to recover...
  ✓ Backup found: config.yaml.bak
  
Restore from backup? [y/n]
```

---

## Recovery Procedures

### Re-authenticate Source

```
claude auth linear

Opening browser for Linear authentication...
[Browser opens OAuth flow]

✓ Linear authenticated successfully
  Credentials stored securely

Running sync to verify...
  Linear: ✓ 5 tasks retrieved

Authentication complete.
```

### Clear Pending Operation

If an operation is stuck and should be abandoned:

```
/clear-pending op-001

Operation: Create task "Update pricing docs" in Linear

This will permanently discard this operation.
The task will NOT be created.

Confirm? [y/n]: y

✓ Operation discarded.
```

### Reset Sync State

If sync state is corrupted:

```
/reset-sync

This will clear all sync timestamps and cached data.
Next brief will fetch everything fresh.

Confirm? [y/n]: y

✓ Sync state reset.
Run /sync to fetch fresh data.
```

---

## Validation

| Check | Expected |
|-------|----------|
| Brief continues when sources fail | ✓ |
| Stale data shows warning | ✓ |
| Failed writes queue correctly | ✓ |
| Auto-retry works | ✓ |
| /status shows accurate info | ✓ |
| /sync processes queue | ✓ |
| Offline mode works | ✓ |
| Critical failures surface | ✓ |

---

## Related Features

- **F10 (External Sources)**: Source definitions and sync
- **F11 (Commands)**: /status, /sync commands
- **F14 (Bootstrap)**: Initial auth setup
