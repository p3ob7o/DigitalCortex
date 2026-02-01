# T03: Daily Note Lifecycle — Tests

## Test Environment

```
test-vault-populated/          ← With daily notes in various states
```

**Mocks:**
- System clock: Configurable date/time
- Timezone: Europe/Vienna (+01:00)

---

## Test Suite: Daily Note Creation

### T03.1: Create daily note with correct filename
**Code type:** Bash script

```pseudo
GIVEN mock date is 2025-01-31 (Friday)
AND no daily note exists for today
WHEN create_daily_note() is executed
THEN file created: 0_Inbox/2025-01-31 Friday.md
```

### T03.2: Filename includes weekday name
**Code type:** Bash script

```pseudo
FOR EACH (date, weekday) in:
  (2025-01-27, Monday)
  (2025-01-28, Tuesday)
  (2025-01-29, Wednesday)
  (2025-01-30, Thursday)
  (2025-01-31, Friday)
  (2025-02-01, Saturday)
  (2025-02-02, Sunday)
GIVEN mock date is $date
WHEN create_daily_note() is executed
THEN filename ends with " $weekday.md"
```

### T03.3: Daily note created in 0_Inbox
**Code type:** Bash script

```pseudo
GIVEN mock date is 2025-01-31
WHEN create_daily_note() is executed
THEN file exists at 0_Inbox/2025-01-31 Friday.md
AND file does NOT exist at 6_Archive/Daily-Notes/2025/01/2025-01-31 Friday.md
```

### T03.4: Daily note has correct frontmatter
**Code type:** Python script

```pseudo
GIVEN newly created daily note
THEN frontmatter contains:
  - type: daily
  - date: 2025-01-31
  - processed: false
  - review_completed: false
  - created: <ISO timestamp with timezone>
  - updated: <ISO timestamp with timezone>
```

### T03.5: Daily note has correct section structure
**Code type:** Python script

```pseudo
GIVEN newly created daily note
THEN body contains sections in order:
  1. ## Morning Brief
  2. ## Captures
  3. ## Evening Review
AND each section is separated by ---
```

### T03.6: Creation is idempotent
**Code type:** Bash script

```pseudo
GIVEN daily note already exists with content in ## Captures
WHEN create_daily_note() is executed again
THEN existing content is preserved
AND no duplicate sections created
AND exit code is 0
```

---

## Test Suite: Archival Rules

### T03.7: Archive when all conditions met
**Code type:** Bash script

```pseudo
GIVEN daily note 2025-01-30 Thursday.md with:
  - date: 2025-01-30
  - processed: true
  - review_completed: true
AND mock date is 2025-01-31 (day has passed)
WHEN archive_daily_notes() is executed
THEN file moved to 6_Archive/Daily-Notes/2025/01/2025-01-30 Thursday.md
AND file no longer exists in 0_Inbox/
```

### T03.8: Do NOT archive when processed=false
**Code type:** Bash script

```pseudo
GIVEN daily note 2025-01-30 Thursday.md with:
  - date: 2025-01-30
  - processed: false
  - review_completed: true
AND mock date is 2025-01-31
WHEN archive_daily_notes() is executed
THEN file remains in 0_Inbox/
AND file NOT in 6_Archive/
```

### T03.9: Do NOT archive when review_completed=false
**Code type:** Bash script

```pseudo
GIVEN daily note 2025-01-30 Thursday.md with:
  - date: 2025-01-30
  - processed: true
  - review_completed: false
AND mock date is 2025-01-31
WHEN archive_daily_notes() is executed
THEN file remains in 0_Inbox/
```

### T03.10: Do NOT archive today's note
**Code type:** Bash script

```pseudo
GIVEN daily note 2025-01-31 Friday.md with:
  - date: 2025-01-31
  - processed: true
  - review_completed: true
AND mock date is 2025-01-31 (same day)
WHEN archive_daily_notes() is executed
THEN file remains in 0_Inbox/
```

### T03.11: Archive creates year/month folders
**Code type:** Bash script

```pseudo
GIVEN daily note from 2025-03-15 ready for archive
AND 6_Archive/Daily-Notes/2025/03/ does not exist
WHEN archive_daily_notes() is executed
THEN directory 6_Archive/Daily-Notes/2025/03/ is created
AND file is moved there
```

### T03.12: Archive preserves file content
**Code type:** Python script

```pseudo
GIVEN daily note with specific content:
  - Morning brief text
  - 3 captures
  - Evening review text
WHEN note is archived
THEN archived file has identical content byte-for-byte
```

---

## Test Suite: Flag Management

### T03.13: Set processed=true
**Code type:** Python script

```pseudo
GIVEN daily note with processed: false
WHEN set_flag("2025-01-31", "processed", true) is executed
THEN frontmatter processed equals true
AND frontmatter updated timestamp is refreshed
```

### T03.14: Set review_completed=true
**Code type:** Python script

```pseudo
GIVEN daily note with review_completed: false
WHEN set_flag("2025-01-31", "review_completed", true) is executed
THEN frontmatter review_completed equals true
AND frontmatter updated timestamp is refreshed
```

### T03.15: Reset flag to false
**Code type:** Python script

```pseudo
GIVEN daily note with processed: true
WHEN set_flag("2025-01-31", "processed", false) is executed
THEN frontmatter processed equals false
```

### T03.16: Setting flag preserves other content
**Code type:** Python script

```pseudo
GIVEN daily note with captures and morning brief content
WHEN set_flag() modifies any flag
THEN all section content is preserved unchanged
```

---

## Test Suite: Listing and Querying

### T03.17: List unprocessed daily notes
**Code type:** Python script

```pseudo
GIVEN 0_Inbox/ contains:
  - 2025-01-29 Wednesday.md (processed: false)
  - 2025-01-30 Thursday.md (processed: true)
  - 2025-01-31 Friday.md (processed: false)
WHEN list_unprocessed_notes() is executed
THEN returns: [2025-01-29 Wednesday.md, 2025-01-31 Friday.md]
AND results sorted by date ascending
```

### T03.18: List notes pending review
**Code type:** Python script

```pseudo
GIVEN 0_Inbox/ contains notes with various review_completed states
WHEN list_pending_review() is executed
THEN returns only notes where review_completed: false
```

### T03.19: Get today's daily note path
**Code type:** Bash script

```pseudo
GIVEN mock date is 2025-01-31
WHEN get_today_note_path() is executed
THEN returns: $VAULT/0_Inbox/2025-01-31 Friday.md
```

### T03.20: Find daily note by date
**Code type:** Bash script

```pseudo
GIVEN daily note exists for 2025-01-30
WHEN find_daily_note("2025-01-30") is executed
THEN returns path to 2025-01-30 Thursday.md
AND checks both 0_Inbox/ and 6_Archive/Daily-Notes/
```

---

## Test Suite: Edge Cases

### T03.21: Handle missing frontmatter
**Code type:** Python script

```pseudo
GIVEN malformed daily note with no frontmatter
WHEN validate_daily_note() is executed
THEN returns error: "Missing frontmatter"
AND does not crash
```

### T03.22: Handle invalid YAML in frontmatter
**Code type:** Python script

```pseudo
GIVEN daily note with malformed YAML:
  ---
  type: daily
  date: [invalid
  ---
WHEN validate_daily_note() is executed
THEN returns error: "Invalid YAML"
```

### T03.23: Handle date mismatch (filename vs frontmatter)
**Code type:** Python script

```pseudo
GIVEN file: 2025-01-31 Friday.md
AND frontmatter date: 2025-01-30
WHEN validate_daily_note() is executed
THEN returns warning: "Date mismatch: filename=2025-01-31, frontmatter=2025-01-30"
```

### T03.24: Handle timezone at midnight boundary
**Code type:** Python script

```pseudo
GIVEN mock time is 2025-02-01T00:30:00+01:00 (Vienna)
WHICH equals 2025-01-31T23:30:00Z (UTC)
WHEN create_daily_note() is executed
THEN creates note for 2025-02-01 (local date)
NOT 2025-01-31 (UTC date)
```

---

## Test Fixtures Required

### test-vault-populated/0_Inbox/ daily notes
```markdown
# 2025-01-29 Wednesday.md
---
type: daily
date: 2025-01-29
processed: false
review_completed: false
created: 2025-01-29T07:00:00+01:00
updated: 2025-01-29T18:00:00+01:00
---

## Morning Brief
Brief content

## Captures
### 10:00
Sample capture

## Evening Review

```

```markdown
# 2025-01-30 Thursday.md (ready for archive)
---
type: daily
date: 2025-01-30
processed: true
review_completed: true
created: 2025-01-30T07:00:00+01:00
updated: 2025-01-30T21:00:00+01:00
---

## Morning Brief
Completed brief

## Captures
### 14:00
Important note

## Evening Review
Review complete
```

```markdown
# 2025-01-31 Friday.md (today)
---
type: daily
date: 2025-01-31
processed: false
review_completed: false
created: 2025-01-31T07:00:00+01:00
updated: 2025-01-31T07:00:00+01:00
---

## Morning Brief

## Captures

## Evening Review

```
