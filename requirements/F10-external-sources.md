# F10: External Source Integration

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F10 |
| Priority | Phase 4 (Integration) |
| Dependencies | F14 (Bootstrap for auth) |
| Dependents | F5, F6, F7, F9 (all features that use external data) |

## Purpose

Connect to external services for pulling context (briefs, reviews) and pushing actions (tasks, reminders, calendar events). Each source has defined read/write permissions and access methods.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F10.1 | Sources configured in 9_Meta/config.yaml | Must |
| F10.2 | Each source can be enabled/disabled | Must |
| F10.3 | Failed sources don't block other sources | Must |
| F10.4 | Stale data (<4h) used with warning | Must |
| F10.5 | Authentication handled securely | Must |
| F10.6 | Last sync time tracked per source | Must |

---

## Source Summary

| Source | Access | Read | Write | History |
|--------|--------|------|-------|---------|
| Gmail | API | Unread + starred (full) | — | Since last brief |
| Calendar | API | Events | Create/edit on request | Today (daily), ±1 week (weekly) |
| Slack | context-a8c MCP | Messages, mentions | — | Since last brief |
| P2 | context-a8c MCP | Posts, comments, mentions | — | Since last brief |
| Linear | API | Issues assigned to user | Totoro only | Active + since brief |
| Reminders | CLI/osascript | All lists | Create | Forward + overdue |

---

## Gmail

### Access Method
Direct API (Google Workspace API)

### Read Configuration

| Setting | Value |
|---------|-------|
| Scope | Unread emails, starred emails |
| Content | Full email body (for context and suggestions) |
| History | Since last brief |
| Filters | Exclude Promotions and Updates categories |
| VIP | None (future enhancement) |

### Data Retrieved

```json
{
  "emails": [
    {
      "id": "msg-123",
      "thread_id": "thread-456",
      "from": "jane@example.com",
      "to": "user@example.com",
      "subject": "RE: Pricing Approval",
      "snippet": "Please review and sign off...",
      "body": "Full email content...",
      "date": "2025-01-31T09:15:00Z",
      "labels": ["INBOX", "IMPORTANT"],
      "is_unread": true
    }
  ]
}
```

### Write Access
None (read-only)

---

## Google Calendar

### Access Method
Direct API (Google Calendar API)

### Read Configuration

| Context | Scope |
|---------|-------|
| Morning Brief | Today's events |
| Evening Review | Today's events |
| Weekly Review | Past week + upcoming week |

### Data Retrieved

```json
{
  "events": [
    {
      "id": "event-123",
      "summary": "Weekly Standup",
      "start": "2025-01-31T10:00:00+01:00",
      "end": "2025-01-31T10:30:00+01:00",
      "location": "Zoom",
      "attendees": [
        {"email": "jane@example.com", "name": "Jane Smith"},
        {"email": "user@example.com", "name": "User", "self": true}
      ],
      "conference_link": "https://zoom.us/..."
    }
  ]
}
```

### Write Access
Create and edit events on explicit user request only.

```
User: "Block 2 hours tomorrow for deep work"
Claude: Creating event...
  Title: Deep Work Block
  Time: 2025-02-01 09:00–11:00
  
  Confirm? [y/n]
```

---

## Slack

### Access Method
context-a8c MCP (custom MCP server)

### Read Configuration

| Setting | Value |
|---------|-------|
| Scope | User's messages, messages mentioning user |
| Context | Surrounding conversation for relevance |
| History | Since last brief |
| Content | Full message content |

### Data Retrieved

```json
{
  "threads": [
    {
      "channel": "#domain-strategy",
      "channel_id": "C123",
      "messages": [
        {
          "user": "U456",
          "user_name": "colleague",
          "text": "Hey @user, what's the status on pricing?",
          "timestamp": "2025-01-31T09:00:00Z",
          "is_mention": true
        },
        {
          "user": "U789",
          "user_name": "user",
          "text": "Working on it, should have update by EOD",
          "timestamp": "2025-01-31T09:05:00Z",
          "is_own": true
        }
      ],
      "thread_url": "https://slack.com/..."
    }
  ]
}
```

### Write Access
None (read-only)

---

## P2 (WordPress)

### Access Method
context-a8c MCP (custom MCP server)

### Read Configuration

| Setting | Value |
|---------|-------|
| Scope | Posts by user, comments by user, mentions of user, replies to user's posts |
| History | Since last brief |
| Content | Full post/comment content |

### Data Retrieved

```json
{
  "items": [
    {
      "type": "post",
      "title": "Domain Bundling Update",
      "author": "user",
      "content": "Here's the latest on...",
      "url": "https://p2.automattic.com/...",
      "date": "2025-01-31T08:00:00Z",
      "comments_count": 3
    },
    {
      "type": "comment",
      "post_title": "Q1 Planning",
      "author": "colleague",
      "content": "@user what do you think about...",
      "is_mention": true,
      "url": "https://p2.automattic.com/...",
      "date": "2025-01-31T10:00:00Z"
    }
  ]
}
```

### Write Access
None (read-only)

---

## Linear

### Access Method
Direct API (Linear GraphQL API)

### Read Configuration

| Setting | Value |
|---------|-------|
| Scope | Issues assigned to user (all teams) |
| Completed | Since last brief |
| History | Active issues (no limit) |

### Data Retrieved

```json
{
  "issues": [
    {
      "id": "issue-123",
      "identifier": "DOMAIN-456",
      "title": "Update pricing documentation",
      "description": "...",
      "state": "In Progress",
      "priority": 2,
      "due_date": "2025-02-14",
      "project": {
        "id": "proj-789",
        "name": "Domain Bundling"
      },
      "labels": [
        {"name": "Domaison"}
      ],
      "team": {
        "id": "team-abc",
        "name": "Domain"
      }
    }
  ],
  "completed_since_last_brief": [
    {
      "identifier": "DOMAIN-123",
      "title": "Review mockups",
      "completed_at": "2025-01-30T16:00:00Z"
    }
  ]
}
```

### Write Access
Totoro team only.

| Operation | Scope |
|-----------|-------|
| Create issue | Totoro |
| Update issue | Totoro |
| Change status | Totoro |
| Add to project | Totoro |

---

## Apple Reminders

### Access Method
CLI or osascript

### Read Configuration

| Setting | Value |
|---------|-------|
| Lists | Reminders, Shopping |
| Scope | Due today, overdue, upcoming 3 days |

### Data Retrieved

```json
{
  "reminders": [
    {
      "list": "Reminders",
      "title": "Call dentist",
      "due": "2025-01-31T10:00:00",
      "completed": false
    }
  ],
  "shopping": [
    {
      "list": "Shopping",
      "title": "Milk",
      "completed": false
    }
  ]
}
```

### Write Access
Create reminders in either list.

```bash
# Create reminder
osascript -e 'tell application "Reminders" to make new reminder in list "Reminders" with properties {name:"Call dentist", due date:date "2025-02-01 10:00:00"}'

# Create shopping item
osascript -e 'tell application "Reminders" to make new reminder in list "Shopping" with properties {name:"Milk"}'
```

---

## Configuration

Sources are configured in `9_Meta/config.yaml`:

```yaml
sources:
  gmail:
    enabled: true
    exclude_categories:
      - PROMOTIONS
      - UPDATES
  
  calendar:
    enabled: true
    calendars: all  # or list specific calendar IDs
  
  slack:
    enabled: true
    mcp: context-a8c
  
  p2:
    enabled: true
    mcp: context-a8c
  
  linear:
    enabled: true
    personal_team: Totoro
    personal_team_id: "team-uuid"
  
  reminders:
    enabled: true
    lists:
      - Reminders
      - Shopping
```

---

## Sync State

Track last sync time for each source in `9_Meta/state.json`:

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
  "last_brief": "2025-01-31T07:30:00Z"
}
```

---

## Validation

| Check | Expected |
|-------|----------|
| All enabled sources accessible | ✓ |
| Authentication valid | ✓ |
| Read permissions work | ✓ |
| Write permissions scoped correctly | ✓ |
| Sync times tracked | ✓ |
| Disabled sources skipped | ✓ |

---

## Related Features

- **F5 (Morning Brief)**: Primary consumer of source data
- **F9 (Task Management)**: Linear and Reminders write
- **F12 (Error Handling)**: Graceful degradation
- **F14 (Bootstrap)**: Initial authentication
