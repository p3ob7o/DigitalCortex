# T10: People Integration — Tests

## Test Environment

```
test-vault-populated/          ← With 8_People/ populated
```

**Mocks:**
- Gmail API (for contact info)
- Calendar API (for meeting history)
- Slack MCP (for interaction history)
- No network calls

---

## Test Suite: People File Structure

### T10.1: Valid person file has required fields
**Code type:** Python script

```pseudo
GIVEN person file jane-smith.md
THEN frontmatter contains:
  - type: person
  - name: "Jane Smith"
  - created: <timestamp>
  - updated: <timestamp>
```

### T10.2: Person file with all optional fields
**Code type:** Python script

```pseudo
GIVEN complete person file
THEN frontmatter may contain:
  - email: jane@verisign.com
  - company: Verisign
  - role: Partner Manager
  - areas: ["[[domaison]]"]
  - last_contact: 2025-01-28
  - slack_handle: @jane
  - linkedin: https://linkedin.com/in/janesmith
```

### T10.3: Person filename convention
**Code type:** Python script

```pseudo
GIVEN person named "Jane Smith"
THEN filename: jane-smith.md (lowercase, hyphenated)
```

---

## Test Suite: People Matching

### T10.4: Match by email
**Code type:** Python script

```pseudo
GIVEN email: jane@verisign.com
AND person file has email: jane@verisign.com
WHEN find_person(email="jane@verisign.com")
THEN returns path to jane-smith.md
```

### T10.5: Match by name (exact)
**Code type:** Python script

```pseudo
GIVEN name: "Jane Smith"
AND person file has name: "Jane Smith"
WHEN find_person(name="Jane Smith")
THEN returns path to jane-smith.md
```

### T10.6: Match by name (partial/fuzzy)
**Code type:** Python script

```pseudo
GIVEN search: "Jane"
AND person files: jane-smith.md, jane-doe.md
WHEN find_person(name="Jane")
THEN returns both matches with confidence scores
```

### T10.7: Match by Slack handle
**Code type:** Python script

```pseudo
GIVEN slack_handle: "@jsmith"
AND person file has slack_handle: "@jsmith"
WHEN find_person(slack="@jsmith")
THEN returns path to person file
```

### T10.8: No match returns null
**Code type:** Python script

```pseudo
GIVEN email: unknown@example.com
AND no person file has this email
WHEN find_person(email="unknown@example.com")
THEN returns null
```

---

## Test Suite: Auto-Creation

### T10.9: Offer to create person from email
**Code type:** Prompt/Response

```pseudo
GIVEN email from unknown sender: john@acme.com
AND no matching person file
WHEN processing email in brief
THEN Claude offers:
  "New contact: john@acme.com
   Create person file? [y/n]"
```

### T10.10: Create person with available info
**Code type:** Python script

```pseudo
GIVEN user confirms person creation
AND available info:
  - email: john@acme.com
  - display_name: "John Doe"
  - company domain: acme.com → "Acme Corp"
WHEN creating person file
THEN file created: 8_People/john-doe.md
AND frontmatter populated with available info
```

### T10.11: Infer company from email domain
**Code type:** Python script

```pseudo
GIVEN email: jane@verisign.com
WHEN creating person file
THEN company field suggests: "Verisign"
```

### T10.12: Handle duplicate detection
**Code type:** Python script

```pseudo
GIVEN new email: jane.smith@verisign.com
AND existing person: jane-smith.md with email: jane@verisign.com
WHEN creating person
THEN Claude asks:
  "Possible duplicate: jane-smith.md (Jane Smith at Verisign)
   [m]erge / [c]reate new / [s]kip"
```

---

## Test Suite: Contact Updates

### T10.13: Update last_contact automatically
**Code type:** Python script

```pseudo
GIVEN config.people.auto_update_contact = true
AND email from jane@verisign.com dated 2025-01-31
AND jane-smith.md has last_contact: 2025-01-28
WHEN processing email
THEN last_contact updated to 2025-01-31
```

### T10.14: Update last_contact from calendar
**Code type:** Python script

```pseudo
GIVEN calendar event today with attendee jane@verisign.com
AND jane-smith.md has last_contact: 2025-01-28
WHEN morning brief shows meeting
THEN offers: "Update last_contact for Jane Smith? [y/n]"
```

### T10.15: Preserve manual last_contact notes
**Code type:** Python script

```pseudo
GIVEN person file has notes under last_contact context
WHEN auto-updating last_contact
THEN date updated
AND context notes preserved
```

---

## Test Suite: Relationship Context

### T10.16: Surface context in morning brief
**Code type:** Python script

```pseudo
GIVEN email from jane@verisign.com
AND jane-smith.md body contains:
  "Primary contact for bulk pricing partnership.
   Last discussion: Q1 volume targets."
WHEN formatting email in brief
THEN includes context:
  "Context: Primary contact for bulk pricing. Last: Q1 volume targets."
```

### T10.17: Surface context in calendar
**Code type:** Python script

```pseudo
GIVEN meeting with jane@verisign.com
WHEN showing in brief
THEN includes:
  "👤 [[jane-smith]] (Verisign Partner Manager)
   Last contact: Jan 28 — discussed Q1 targets"
```

### T10.18: Show interaction history
**Code type:** Prompt/Response

```pseudo
GIVEN user asks: "What's my history with Jane Smith?"
WHEN Claude searches vault
THEN compiles:
  - All notes mentioning [[jane-smith]]
  - Meeting history from calendar
  - Email threads from gmail
  - Slack DM history
```

---

## Test Suite: Areas Integration

### T10.19: Link person to areas
**Code type:** Python script

```pseudo
GIVEN jane-smith.md has areas: ["[[domaison]]"]
WHEN enriching area context
THEN domaison.md includes Jane in related people
```

### T10.20: Suggest areas for new person
**Code type:** Prompt/Response

```pseudo
GIVEN creating person from email about domain pricing
WHEN suggesting areas
THEN Claude suggests: "Related to [[domaison]]? [y/n]"
```

---

## Test Suite: Search and Query

### T10.21: List all people
**Code type:** Python script

```pseudo
GIVEN 8_People/ has 5 person files
WHEN list_people()
THEN returns 5 person entries with basic info
```

### T10.22: List people by area
**Code type:** Python script

```pseudo
GIVEN request: people in area "domaison"
WHEN list_people(area="domaison")
THEN returns people where areas contains [[domaison]]
```

### T10.23: List people by company
**Code type:** Python script

```pseudo
GIVEN request: people at Verisign
WHEN list_people(company="Verisign")
THEN returns people where company contains "Verisign"
```

### T10.24: Find recently contacted
**Code type:** Python script

```pseudo
GIVEN request: people contacted in last 7 days
WHEN list_people(last_contact_within=7)
THEN returns people with last_contact >= 7 days ago
```

---

## Test Suite: External Source Integration

### T10.25: Pull contact info from Gmail
**Code type:** Python script

```pseudo
GIVEN mock Gmail API returns contact info for john@acme.com:
  - display_name: "John Doe"
  - photo_url: "https://..."
WHEN creating person file
THEN info populated from Gmail
```

### T10.26: Pull interaction history from Slack
**Code type:** Python script

```pseudo
GIVEN mock Slack MCP returns DM history with @jane
WHEN generating person context
THEN recent DM topics included in context
```

---

## Test Suite: Error Handling

### T10.27: Handle invalid email format
**Code type:** Python script

```pseudo
GIVEN email: "not-an-email"
WHEN find_person(email="not-an-email")
THEN returns null
AND does not error
```

### T10.28: Handle missing People folder
**Code type:** Python script

```pseudo
GIVEN 8_People/ doesn't exist
WHEN find_person() called
THEN creates 8_People/ folder
AND continues with empty result
```

### T10.29: Handle duplicate filenames
**Code type:** Python script

```pseudo
GIVEN jane-smith.md already exists
AND creating new person named "Jane Smith"
WHEN generating filename
THEN creates jane-smith-2.md or prompts for different name
```

---

## Mock Fixtures

### People files
```yaml
# 8_People/jane-smith.md
---
type: person
name: Jane Smith
email: jane@verisign.com
company: Verisign
role: Partner Manager
areas: ["[[domaison]]"]
last_contact: 2025-01-28
slack_handle: "@jsmith"
created: 2025-01-10T10:00:00+01:00
updated: 2025-01-28T16:00:00+01:00
---

## Context

Primary contact for bulk pricing partnership.
Works with their enterprise sales team.

## Last Discussion

Jan 28: Discussed Q1 volume targets and discount structure.
She mentioned they're interested in domain bundling.

## Notes

- Prefers email over Slack
- Based in Reston, VA (EST timezone)
- Reports to VP of Partnerships
```

```yaml
# 8_People/john-doe.md
---
type: person
name: John Doe
email: john@acme.com
company: Acme Corp
created: 2025-01-20T10:00:00+01:00
updated: 2025-01-20T10:00:00+01:00
---
```
