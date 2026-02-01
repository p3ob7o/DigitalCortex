# T04: Frontmatter Schemas — Tests

## Test Environment

```
test-vault-populated/          ← With sample files of each type
```

---

## Test Suite: Common Fields

### T04.1: All entities have 'type' field
**Code type:** Python script

```pseudo
FOR EACH file_type in [project, area, person, fleeting, draft, daily, resource, capture]:
  GIVEN a valid $file_type file
  WHEN parsing frontmatter
  THEN 'type' field exists
  AND 'type' equals $file_type
```

### T04.2: All entities have 'created' timestamp
**Code type:** Python script

```pseudo
FOR EACH file in test vault:
  GIVEN file has frontmatter
  WHEN parsing frontmatter
  THEN 'created' field exists
  AND 'created' is valid ISO 8601 with timezone
```

### T04.3: All entities have 'updated' timestamp
**Code type:** Python script

```pseudo
FOR EACH file in test vault:
  GIVEN file has frontmatter
  WHEN parsing frontmatter
  THEN 'updated' field exists
  AND 'updated' is valid ISO 8601 with timezone
  AND 'updated' >= 'created'
```

### T04.4: Timestamps include timezone offset
**Code type:** Python script

```pseudo
GIVEN any file with frontmatter
WHEN examining created and updated fields
THEN both match pattern: \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}
EXAMPLES:
  - 2025-01-31T14:30:00+01:00 ✓
  - 2025-01-31T14:30:00Z ✓ (Z = +00:00)
  - 2025-01-31T14:30:00 ✗ (no timezone)
```

---

## Test Suite: Project Schema

### T04.5: Project has required fields
**Code type:** Python script

```pseudo
GIVEN a valid project file
THEN frontmatter contains:
  - type: project
  - status: (one of: active, paused, completed, dropped)
  - created: <timestamp>
  - updated: <timestamp>
```

### T04.6: Project optional fields validate correctly
**Code type:** Python script

```pseudo
GIVEN a project with all optional fields:
  ---
  type: project
  status: active
  areas: ["[[domaison]]", "[[work]]"]
  linear_project: proj-abc123
  start: 2025-01-15
  due: 2025-03-31
  next_action: Review pricing proposal
  ---
WHEN validating frontmatter
THEN all fields are valid
AND areas is a list of wiki-links
AND start/due are valid dates
```

### T04.7: Project status values constrained
**Code type:** Python script

```pseudo
FOR EACH status in [active, paused, completed, dropped]:
  GIVEN project with status: $status
  WHEN validating
  THEN validation passes

GIVEN project with status: "invalid-status"
WHEN validating
THEN validation fails with "Invalid status value"
```

---

## Test Suite: Area Schema

### T04.8: Area has required fields
**Code type:** Python script

```pseudo
GIVEN a valid area file
THEN frontmatter contains:
  - type: area
  - created: <timestamp>
  - updated: <timestamp>
```

### T04.9: Area optional fields validate correctly
**Code type:** Python script

```pseudo
GIVEN an area with optional fields:
  ---
  type: area
  linear_label: Domaison
  active: true
  ---
WHEN validating frontmatter
THEN all fields are valid
AND active is boolean
```

---

## Test Suite: Person Schema

### T04.10: Person has required fields
**Code type:** Python script

```pseudo
GIVEN a valid person file
THEN frontmatter contains:
  - type: person
  - name: <string>
  - created: <timestamp>
  - updated: <timestamp>
```

### T04.11: Person optional fields validate correctly
**Code type:** Python script

```pseudo
GIVEN a person with all fields:
  ---
  type: person
  name: Jane Smith
  email: jane@verisign.com
  company: Verisign
  role: Partner Manager
  areas: ["[[domaison]]"]
  last_contact: 2025-01-28
  ---
WHEN validating frontmatter
THEN all fields are valid
AND email is valid email format
AND last_contact is valid date
```

### T04.12: Person email format validation
**Code type:** Python script

```pseudo
GIVEN person with email: "not-an-email"
WHEN validating
THEN validation fails with "Invalid email format"

GIVEN person with email: "valid@example.com"
WHEN validating
THEN validation passes
```

---

## Test Suite: Daily Schema

### T04.13: Daily note has required fields
**Code type:** Python script

```pseudo
GIVEN a valid daily note
THEN frontmatter contains:
  - type: daily
  - date: YYYY-MM-DD
  - processed: boolean
  - review_completed: boolean
  - created: <timestamp>
  - updated: <timestamp>
```

### T04.14: Daily date format validation
**Code type:** Python script

```pseudo
GIVEN daily with date: "2025-01-31"
WHEN validating
THEN validation passes

GIVEN daily with date: "01/31/2025"
WHEN validating
THEN validation fails with "Invalid date format, expected YYYY-MM-DD"
```

---

## Test Suite: Capture Schema

### T04.15: Capture has required fields
**Code type:** Python script

```pseudo
GIVEN a valid capture file
THEN frontmatter contains:
  - type: capture
  - source: <string>
  - captured: <timestamp>
  - created: <timestamp>
  - updated: <timestamp>
```

### T04.16: Capture source-specific fields
**Code type:** Python script

```pseudo
GIVEN slack capture
THEN frontmatter contains:
  - source: slack
  - channel: <string>
  - from: <string>

GIVEN email capture
THEN frontmatter contains:
  - source: email
  - from: <email>
  - subject: <string>

GIVEN web capture
THEN frontmatter contains:
  - source: web
  - url: <url>

GIVEN voice-memo capture
THEN frontmatter contains:
  - source: voice-memo
  - duration: <string or number>
  - transcription_service: cloud | local
```

---

## Test Suite: Fleeting Schema

### T04.17: Fleeting has required fields
**Code type:** Python script

```pseudo
GIVEN a valid fleeting note
THEN frontmatter contains:
  - type: fleeting
  - created: <timestamp>
  - updated: <timestamp>
```

### T04.18: Fleeting optional fields
**Code type:** Python script

```pseudo
GIVEN fleeting with optional fields:
  ---
  type: fleeting
  source: conversation
  topics: ["pricing", "domains"]
  ---
WHEN validating
THEN all fields are valid
AND topics is a list of strings
```

---

## Test Suite: Draft Schema

### T04.19: Draft has required fields
**Code type:** Python script

```pseudo
GIVEN a valid draft file
THEN frontmatter contains:
  - type: draft
  - status: <string>
  - created: <timestamp>
  - updated: <timestamp>
```

### T04.20: Draft status values constrained
**Code type:** Python script

```pseudo
FOR EACH status in [outline, drafting, review, final]:
  GIVEN draft with status: $status
  WHEN validating
  THEN validation passes
```

### T04.21: Draft optional fields
**Code type:** Python script

```pseudo
GIVEN draft with:
  ---
  type: draft
  status: drafting
  target: P2 blog post
  areas: ["[[domaison]]"]
  due: 2025-02-15
  ---
WHEN validating
THEN all fields are valid
```

---

## Test Suite: Resource Schema

### T04.22: Resource has required fields
**Code type:** Python script

```pseudo
GIVEN a valid resource file
THEN frontmatter contains:
  - type: resource
  - created: <timestamp>
  - updated: <timestamp>
```

### T04.23: Resource optional fields
**Code type:** Python script

```pseudo
GIVEN resource with:
  ---
  type: resource
  url: https://example.com/article
  author: John Doe
  tags: ["pricing", "strategy"]
  ---
WHEN validating
THEN url is valid URL format
AND tags is list of strings
```

---

## Test Suite: Wiki-Link Format

### T04.24: Wiki-links use correct format
**Code type:** Python script

```pseudo
GIVEN frontmatter with link fields:
  areas: ["[[domaison]]", "[[work]]"]
WHEN validating
THEN each link matches pattern: \[\[.+\]\]
```

### T04.25: Wiki-links are resolvable
**Code type:** Python script

```pseudo
GIVEN project with areas: ["[[domaison]]"]
AND 4_Areas/domaison.md exists
WHEN validating with resolve_links=true
THEN validation passes

GIVEN project with areas: ["[[nonexistent]]"]
AND 4_Areas/nonexistent.md does NOT exist
WHEN validating with resolve_links=true
THEN validation warns: "Unresolved link: [[nonexistent]]"
```

---

## Test Suite: Schema Validation Function

### T04.26: Validate file against schema
**Code type:** Python script

```pseudo
GIVEN file with type: project
WHEN validate_frontmatter(file, schema="project")
THEN checks all required fields
AND checks field types
AND returns {valid: bool, errors: [], warnings: []}
```

### T04.27: Auto-detect schema from type field
**Code type:** Python script

```pseudo
GIVEN file with type: person
WHEN validate_frontmatter(file) (no explicit schema)
THEN automatically validates against person schema
```

### T04.28: Report all validation errors
**Code type:** Python script

```pseudo
GIVEN file with multiple issues:
  - missing required field 'status'
  - invalid date format
  - unknown field 'foo'
WHEN validate_frontmatter(file)
THEN returns all errors, not just first one
```

---

## Test Fixtures Required

### Sample files for each type
```yaml
# 3_Projects/test-project/test-project.md
---
type: project
status: active
areas: ["[[test-area]]"]
linear_project: proj-test123
start: 2025-01-15
due: 2025-03-31
next_action: Complete phase 1
created: 2025-01-15T10:00:00+01:00
updated: 2025-01-31T14:00:00+01:00
---

# 4_Areas/test-area.md
---
type: area
linear_label: TestLabel
active: true
created: 2025-01-01T10:00:00+01:00
updated: 2025-01-31T14:00:00+01:00
---

# 8_People/jane-smith.md
---
type: person
name: Jane Smith
email: jane@verisign.com
company: Verisign
role: Partner Manager
areas: ["[[test-area]]"]
last_contact: 2025-01-28
created: 2025-01-10T10:00:00+01:00
updated: 2025-01-28T16:00:00+01:00
---
```
