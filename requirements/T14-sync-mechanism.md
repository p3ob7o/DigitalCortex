# T14: Sync Mechanism — Tests

## Test Environment

```
test-vault-populated/          ← With state.json tracking sync times
```

**Mocks:**
- All external source APIs
- System clock
- Network conditions

---

## Test Suite: Trigger Recognition

### T14.1: CLI trigger: claude sync
**Code type:** Bash script

```pseudo
GIVEN valid vault configuration
WHEN executing: claude sync
THEN sync_all() function is invoked
```

### T14.2: Sync specific source
**Code type:** Bash script

```pseudo
GIVEN command: claude sync gmail
WHEN executed
THEN only gmail sync runs
AND other sources unchanged
```

### T14.3: Slash command triggers
**Code type:** Prompt/Response

```pseudo
FOR EACH command in ["/sync", "/refresh"]:
  GIVEN active Claude session
  WHEN user sends: $command
  THEN sync is triggered
```

---

## Test Suite: Source Sync

### T14.4: Sync Gmail
**Code type:** Python script

```pseudo
GIVEN mock Gmail API returns new data
WHEN sync_source("gmail")
THEN fetches emails since last_sync.gmail
AND updates state.json last_sync.gmail
AND returns sync result
```

### T14.5: Sync Calendar
**Code type:** Python script

```pseudo
GIVEN mock Calendar API returns events
WHEN sync_source("calendar")
THEN fetches events for configured range
AND updates state.json last_sync.calendar
```

### T14.6: Sync Slack via MCP
**Code type:** Python script

```pseudo
GIVEN mock MCP returns messages
WHEN sync_source("slack")
THEN fetches via context-a8c MCP
AND updates state.json last_sync.slack
```

### T14.7: Sync P2 via MCP
**Code type:** Python script

```pseudo
GIVEN mock MCP returns P2 data
WHEN sync_source("p2")
THEN fetches via context-a8c MCP
AND updates state.json last_sync.p2
```

### T14.8: Sync Linear
**Code type:** Python script

```pseudo
GIVEN mock Linear API returns issues
WHEN sync_source("linear")
THEN fetches assigned issues
AND updates state.json last_sync.linear
```

### T14.9: Sync Reminders
**Code type:** Python script

```pseudo
GIVEN mock osascript returns reminders
WHEN sync_source("reminders")
THEN fetches from Apple Reminders
AND updates state.json last_sync.reminders
```

---

## Test Suite: Parallel Execution

### T14.10: Sync sources in parallel
**Code type:** Python script

```pseudo
GIVEN 6 sources enabled
AND each takes 500ms to sync
WHEN sync_all() executed
THEN total time < 2000ms (parallel, not 3000ms sequential)
```

### T14.11: Independent source failures
**Code type:** Python script

```pseudo
GIVEN gmail sync fails
AND other sources succeed
WHEN sync_all() executed
THEN 5 sources complete successfully
AND gmail failure reported
AND exit code indicates partial success
```

---

## Test Suite: State Tracking

### T14.12: Update last_sync timestamps
**Code type:** Python script

```pseudo
GIVEN sync completes for gmail at 08:00:00
WHEN checking state.json
THEN last_sync.gmail = "2025-01-31T08:00:00+01:00"
```

### T14.13: Use last_sync for incremental fetch
**Code type:** Python script

```pseudo
GIVEN last_sync.gmail = "2025-01-31T06:00:00+01:00"
WHEN syncing gmail
THEN fetch includes: since="2025-01-31T06:00:00+01:00"
AND only new emails retrieved
```

### T14.14: Handle first sync (no last_sync)
**Code type:** Python script

```pseudo
GIVEN state.json last_sync.gmail = null
WHEN syncing gmail
THEN fetches reasonable default (last 24h or configured period)
AND sets last_sync for future syncs
```

---

## Test Suite: Sync Status Reporting

### T14.15: Report sync success
**Code type:** Bash script

```pseudo
WHEN sync_all() completes successfully
THEN output shows:
  "Sync complete:
   ✓ Gmail (12 new)
   ✓ Calendar (5 events)
   ✓ Slack (3 mentions)
   ✓ P2 (1 comment)
   ✓ Linear (8 tasks)
   ✓ Reminders (4 due)"
```

### T14.16: Report sync failures
**Code type:** Bash script

```pseudo
GIVEN gmail auth expired
WHEN sync_all() runs
THEN output shows:
  "Sync complete with errors:
   ✗ Gmail — Auth expired (run `claude auth gmail`)
   ✓ Calendar (5 events)
   ..."
```

### T14.17: Report sync duration
**Code type:** Bash script

```pseudo
WHEN sync_all() completes
THEN output includes: "Sync completed in 1.2s"
```

---

## Test Suite: Caching

### T14.18: Cache sync results
**Code type:** Python script

```pseudo
GIVEN sync just completed
AND cache TTL = 5 minutes
WHEN requesting data within 5 minutes
THEN cached data returned
AND no API call made
```

### T14.19: Cache invalidation on explicit sync
**Code type:** Python script

```pseudo
GIVEN cached data from 2 minutes ago
WHEN user runs explicit sync
THEN cache invalidated
AND fresh data fetched
```

### T14.20: Cache expiration
**Code type:** Python script

```pseudo
GIVEN cached data from 10 minutes ago
AND cache TTL = 5 minutes
WHEN requesting data
THEN cache miss
AND fresh data fetched
```

---

## Test Suite: Background Sync

### T14.21: Sync before morning brief
**Code type:** Python script

```pseudo
GIVEN morning brief triggered
WHEN sync data older than threshold
THEN background sync triggered first
AND brief waits for sync completion
```

### T14.22: Skip sync if recent
**Code type:** Python script

```pseudo
GIVEN last sync < 5 minutes ago
WHEN morning brief triggered
THEN skip sync
AND use cached data
```

---

## Test Suite: Error Handling

### T14.23: Handle auth expired
**Code type:** Python script

```pseudo
GIVEN Gmail returns 401 Unauthorized
WHEN syncing
THEN error stored: {source: "gmail", error: "auth_expired"}
AND message: "Gmail: Re-authenticate with `claude auth gmail`"
```

### T14.24: Handle network timeout
**Code type:** Python script

```pseudo
GIVEN source times out after 30s
WHEN syncing
THEN retries once with backoff
AND if still fails, error: "Network timeout"
```

### T14.25: Handle rate limiting
**Code type:** Python script

```pseudo
GIVEN source returns 429 Too Many Requests
WHEN syncing
THEN respects Retry-After header if present
OR uses exponential backoff
AND reports rate limit status
```

### T14.26: Handle MCP unavailable
**Code type:** Python script

```pseudo
GIVEN context-a8c MCP not responding
WHEN syncing slack or p2
THEN error: "MCP server unavailable"
AND suggests checking MCP setup
```

### T14.27: Handle partial data
**Code type:** Python script

```pseudo
GIVEN Calendar returns incomplete data
WHEN syncing
THEN logs warning
AND returns partial data rather than failing
```

---

## Test Suite: Sync Configuration

### T14.28: Respect disabled sources
**Code type:** Python script

```pseudo
GIVEN config.sources.slack.enabled = false
WHEN sync_all() runs
THEN slack sync skipped
AND no error for skipped source
```

### T14.29: Respect custom sync interval
**Code type:** Python script

```pseudo
GIVEN config.sync.min_interval = 300 (5 minutes)
AND last sync was 3 minutes ago
WHEN sync requested
THEN warning: "Last sync was 3 minutes ago. Sync anyway? [y/n]"
```

---

## Test Suite: Health Check

### T14.30: Check all connections
**Code type:** Bash script

```pseudo
GIVEN command: claude sync --check
WHEN executed
THEN tests connectivity to all sources:
  "Connection check:
   ✓ Gmail — connected
   ✓ Calendar — connected
   ✗ Slack MCP — connection refused
   ✓ Linear — connected
   ✓ Reminders — available"
```

### T14.31: Check specific source
**Code type:** Bash script

```pseudo
GIVEN command: claude sync --check gmail
WHEN executed
THEN tests only gmail connectivity
```

---

## Mock Fixtures

### state.json sync timestamps
```json
{
  "last_sync": {
    "gmail": "2025-01-31T07:55:00+01:00",
    "calendar": "2025-01-31T07:55:00+01:00",
    "slack": "2025-01-31T07:55:00+01:00",
    "p2": "2025-01-31T07:55:00+01:00",
    "linear": "2025-01-31T07:55:00+01:00",
    "reminders": "2025-01-31T07:55:00+01:00"
  }
}
```

### Sync result mock
```python
MOCK_SYNC_RESULTS = {
    "gmail": {"success": True, "count": 12, "duration_ms": 450},
    "calendar": {"success": True, "count": 5, "duration_ms": 200},
    "slack": {"success": True, "count": 3, "duration_ms": 800},
    "p2": {"success": True, "count": 1, "duration_ms": 600},
    "linear": {"success": True, "count": 8, "duration_ms": 350},
    "reminders": {"success": True, "count": 4, "duration_ms": 100}
}
```
