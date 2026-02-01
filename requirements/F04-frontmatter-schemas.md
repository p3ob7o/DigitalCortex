# F4: Frontmatter Schemas

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F4 |
| Priority | Phase 2 (Capture & Processing) |
| Dependencies | F1 (Vault Structure) |
| Dependents | All features that query or create entities |

## Purpose

Define structured metadata for all entity types in the vault. Frontmatter makes the vault queryable—Claude can answer questions like "which projects are blocked?" or "who haven't I contacted this month?" by reading YAML, not parsing prose.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F4.1 | All entities have: type, created, updated | Must |
| F4.2 | Timestamps use ISO 8601 format with timezone | Must |
| F4.3 | Links use Obsidian wiki-link syntax: `"[[target]]"` | Must |
| F4.4 | Claude updates `updated` timestamp on every file modification | Must |
| F4.5 | Status values map to Linear states where applicable | Must |
| F4.6 | Schemas are documented in 9_Meta for reference | Should |

---

## Common Fields

All entities include these base fields:

```yaml
type: <entity-type>              # Identifies schema to use
created: 2025-01-15T09:00:00+01:00
updated: 2025-01-31T14:30:00+01:00
```

---

## Entity Schemas

### Project

**Location**: `3_Projects/{name}/{name}.md`

```yaml
---
type: project
status: backlog | in-progress | paused | completed | canceled
areas:
  - "[[domaison]]"
  - "[[jetpack]]"
linear_project: "project-uuid-here"
start: 2025-01-15
due: 2025-03-01
next_action: "Draft pricing proposal"
created: 2025-01-15T09:00:00+01:00
updated: 2025-01-31T14:30:00+01:00
---
```

| Field | Type | Description |
|-------|------|-------------|
| status | enum | Maps to Linear project states |
| areas | list | Links to related Area files |
| linear_project | string | Linear project ID for sync |
| start | date | When project began |
| due | date | Target completion (optional) |
| next_action | string | GTD next action (optional) |

**Status Values** (mapped to Linear):
- `backlog` — Not yet started
- `in-progress` — Actively working
- `paused` — Temporarily on hold
- `completed` — Successfully finished
- `canceled` — Abandoned

---

### Area

**Location**: `4_Areas/{name}.md`

```yaml
---
type: area
linear_label: "label-uuid-here"
active: true
created: 2024-06-01T10:00:00+01:00
updated: 2025-01-31T14:30:00+01:00
---
```

| Field | Type | Description |
|-------|------|-------------|
| linear_label | string | Linear label ID for sync |
| active | boolean | Currently relevant? |

Areas are intentionally minimal. Their richness comes from backlinks—projects, people, and resources that reference them.

---

### Person

**Location**: `8_People/{name}.md`

```yaml
---
type: person
name: "Jane Smith"
email: "jane@example.com"
company: "Verisign"
role: "Partner Manager"
areas:
  - "[[domaison]]"
last_contact: 2025-01-28
created: 2024-08-15T11:00:00+01:00
updated: 2025-01-28T16:00:00+01:00
---
```

| Field | Type | Description |
|-------|------|-------------|
| name | string | Full display name |
| email | string | Primary email address |
| company | string | Organization (optional) |
| role | string | Job title or relationship |
| areas | list | Work areas they relate to |
| last_contact | date | Most recent interaction |

---

### Fleeting Note

**Location**: `1_Fleeting/{name}.md`

```yaml
---
type: fleeting
source: voice-memo | slack | email | web | manual
topics:
  - transfer-pricing
  - ux-design
created: 2025-01-31T09:15:00+01:00
updated: 2025-01-31T09:15:00+01:00
---
```

| Field | Type | Description |
|-------|------|-------------|
| source | enum | How this was captured |
| topics | list | Freeform topic tags |

---

### Draft

**Location**: `2_Drafts/{name}/{name}.md`

```yaml
---
type: draft
target: blog | p2 | internal
status: idea | outlining | writing | editing | ready
areas:
  - "[[domaison]]"
due: 2025-02-15
created: 2025-01-20T10:00:00+01:00
updated: 2025-01-31T11:45:00+01:00
---
```

| Field | Type | Description |
|-------|------|-------------|
| target | enum | Publication destination |
| status | enum | Writing stage |
| areas | list | Related areas |
| due | date | Publication deadline (optional) |

**Target Values**:
- `blog` — Personal blog (paolo.blog, ttl.blog)
- `p2` — Internal Automattic P2
- `internal` — Other internal docs

**Status Values**:
- `idea` — Just a concept
- `outlining` — Structuring
- `writing` — First draft
- `editing` — Revising
- `ready` — Ready to publish

---

### Daily Note

**Location**: `0_Inbox/{YYYY-MM-DD dddd}.md`

```yaml
---
type: daily
date: 2025-01-31
processed: false
review_completed: false
created: 2025-01-31T07:00:00+01:00
updated: 2025-01-31T22:00:00+01:00
---
```

| Field | Type | Description |
|-------|------|-------------|
| date | date | The day this note represents |
| processed | boolean | All inbox items addressed? |
| review_completed | boolean | Evening review done? |

---

### Resource

**Location**: `5_Resources/{name}.md`

```yaml
---
type: resource
url: "https://example.com/article"
author: "Author Name"
tags:
  - domain-pricing
  - market-research
created: 2025-01-20T14:00:00+01:00
updated: 2025-01-20T14:00:00+01:00
---
```

| Field | Type | Description |
|-------|------|-------------|
| url | string | Source URL (optional) |
| author | string | Original author (optional) |
| tags | list | Freeform topic tags |

---

### Captured Item (Inbox)

**Location**: `0_Inbox/{descriptive-name}.md`

```yaml
---
type: capture
captured: 2025-01-31T14:23:00+01:00
source: slack | email | web | voice-memo | manual
# Source-specific fields vary
created: 2025-01-31T14:23:00+01:00
updated: 2025-01-31T14:23:00+01:00
---
```

Additional fields by source:

**Slack**:
```yaml
channel: "#domain-strategy"
from: "@colleague"
thread_url: "https://..."
```

**Email**:
```yaml
from: "sender@example.com"
subject: "RE: Pricing"
```

**Web**:
```yaml
url: "https://..."
title: "Page Title"
```

---

## Timestamp Handling

### Format

All timestamps use ISO 8601 with timezone:

```
2025-01-31T14:30:00+01:00
```

### When to Update

| Event | Update `updated`? |
|-------|-------------------|
| Any file modification by Claude | Yes |
| User edits via Obsidian | Yes (if detectable) |
| Read-only access | No |

Claude should update `updated` on every write operation, regardless of how minor.

---

## Link Format

Use Obsidian wiki-link syntax in YAML:

```yaml
areas:
  - "[[domaison]]"
  - "[[jetpack]]"
```

Quotes are required in YAML. This enables:
- Obsidian's backlink tracking
- Graph view connections
- Click-through navigation

---

## Querying

With consistent frontmatter, Claude can query the vault:

```
"Show me blocked projects"
→ Find files where type=project AND status=paused

"Who haven't I contacted in 30 days?"
→ Find files where type=person AND last_contact < (today - 30)

"What fleeting notes are older than a week?"
→ Find files where type=fleeting AND created < (today - 7)
```

---

## Validation

| Check | Expected |
|-------|----------|
| All files have `type` field | ✓ |
| All files have `created` and `updated` | ✓ |
| Timestamps are valid ISO 8601 | ✓ |
| Links use `"[[name]]"` format | ✓ |
| Enum fields use valid values | ✓ |

---

## Related Features

- **F5-F8 (Processing)**: Read and update frontmatter
- **F9 (Task Management)**: Uses linear_project, linear_label
- **F11 (Commands)**: Queries based on frontmatter
- **F15 (People)**: Uses person schema
