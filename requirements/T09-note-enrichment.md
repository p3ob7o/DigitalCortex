# T09: Note Enrichment — Tests

## Test Environment

```
test-vault-populated/          ← With notes, projects, people files
```

**Mocks:**
- User input (interactive approval)
- System clock: 2025-01-31T15:00:00+01:00

---

## Test Suite: Trigger Recognition

### T09.1: CLI trigger: claude enrich
**Code type:** Bash script

```pseudo
GIVEN valid vault with notes
WHEN executing: claude enrich [note-path]
THEN note_enrichment() function is invoked for specified note
```

### T09.2: Slash command triggers
**Code type:** Prompt/Response

```pseudo
FOR EACH command in ["/enrich", "/enhance"]:
  GIVEN active Claude session with note context
  WHEN user sends: $command
  THEN enrichment is triggered for current note
```

### T09.3: Auto-enrich on filing
**Code type:** Python script

```pseudo
GIVEN config.behavior.auto_enrich = true
AND file just moved to 3_Projects/
WHEN filing completes
THEN enrichment automatically triggered
```

---

## Test Suite: Frontmatter Completion

### T09.4: Add missing required fields
**Code type:** Python script

```pseudo
GIVEN note with incomplete frontmatter:
  ---
  type: project
  ---
WHEN enrich_frontmatter(note) is called
THEN frontmatter completed:
  ---
  type: project
  status: active
  created: <inferred or current timestamp>
  updated: <current timestamp>
  ---
```

### T09.5: Preserve existing fields
**Code type:** Python script

```pseudo
GIVEN note with:
  ---
  type: project
  status: paused
  custom_field: value
  ---
WHEN enrich_frontmatter(note)
THEN status remains "paused"
AND custom_field preserved
```

### T09.6: Infer 'created' from file metadata
**Code type:** Python script

```pseudo
GIVEN note without 'created' field
AND filesystem shows creation time: 2025-01-15T10:00:00
WHEN enrich_frontmatter(note)
THEN created field set to 2025-01-15T10:00:00+01:00
```

### T09.7: Suggest areas based on content
**Code type:** Prompt/Response

```pseudo
GIVEN note content mentions "domain", "pricing", "transfers"
AND area "domaison" exists with keywords matching
WHEN enriching frontmatter
THEN Claude suggests:
  "Suggested areas: [[domaison]]
   Accept? [y/n/m]odify"
```

---

## Test Suite: Link Suggestions

### T09.8: Detect potential wiki-links
**Code type:** Python script

```pseudo
GIVEN note content: "Discussed with Jane Smith about domain bundling"
AND 8_People/jane-smith.md exists
AND 3_Projects/domain-bundling/ exists
WHEN detect_potential_links(note)
THEN suggestions:
  - "Jane Smith" → [[jane-smith]]
  - "domain bundling" → [[domain-bundling]]
```

### T09.9: Suggest project links
**Code type:** Prompt/Response

```pseudo
GIVEN note mentions "BI Phase 1"
AND project "bi-phase-1" exists
WHEN presenting link suggestions
THEN Claude suggests:
  "Link 'BI Phase 1' to [[bi-phase-1]]? [y/n]"
```

### T09.10: Suggest people links
**Code type:** Prompt/Response

```pseudo
GIVEN note mentions "@jane" or "Jane Smith"
AND person "jane-smith" exists
WHEN presenting link suggestions
THEN Claude suggests:
  "Link 'Jane Smith' to [[jane-smith]]? [y/n]"
```

### T09.11: Apply approved links
**Code type:** Python script

```pseudo
GIVEN user approves link: "Jane Smith" → [[jane-smith]]
WHEN applying enrichment
THEN note content updated:
  "Discussed with [[jane-smith|Jane Smith]] about..."
```

### T09.12: Preserve existing links
**Code type:** Python script

```pseudo
GIVEN note already has [[jane-smith]] link
WHEN detecting potential links
THEN "Jane Smith" not suggested again
```

---

## Test Suite: Backlink Creation

### T09.13: Add backlink to project
**Code type:** Python script

```pseudo
GIVEN note filed to 3_Projects/domain-bundling/
WHEN creating backlinks
THEN domain-bundling.md gets reference to the note
OR note appears in project's related files
```

### T09.14: Add backlink to person
**Code type:** Python script

```pseudo
GIVEN note links to [[jane-smith]]
WHEN creating backlinks
THEN jane-smith.md updated with reference to note
AND last_contact updated if this is recent interaction
```

### T09.15: Update last_contact on person mention
**Code type:** Python script

```pseudo
GIVEN note dated 2025-01-31 links to [[jane-smith]]
AND jane-smith.md has last_contact: 2025-01-28
WHEN enriching
THEN Claude asks:
  "Update last_contact for Jane Smith to 2025-01-31? [y/n]"
```

---

## Test Suite: Tag Suggestions

### T09.16: Suggest tags based on content
**Code type:** Prompt/Response

```pseudo
GIVEN note content about pricing strategy
AND existing tags in vault include: #pricing, #strategy, #domains
WHEN analyzing for tags
THEN suggests: "Add tags: #pricing, #strategy? [y/n]"
```

### T09.17: Learn from existing tag patterns
**Code type:** Python script

```pseudo
GIVEN similar notes in vault have tags: #meeting-notes
WHEN suggesting tags
THEN includes #meeting-notes if content is meeting-related
```

---

## Test Suite: Content Enhancement

### T09.18: Offer to add summary
**Code type:** Prompt/Response

```pseudo
GIVEN note without summary section
AND note has substantial content
WHEN enriching
THEN Claude offers:
  "Add a summary section at the top? [y/n]"
WHEN user confirms
THEN Claude generates summary from content
```

### T09.19: Offer to extract action items
**Code type:** Prompt/Response

```pseudo
GIVEN note content contains:
  "We need to review the proposal by Friday"
  "Jane will send the updated figures"
WHEN enriching
THEN Claude identifies:
  "Action items detected:
   - Review proposal (due: Friday)
   - Jane: Send updated figures
   
   Extract as tasks? [y/n]"
```

### T09.20: Offer to create tasks from action items
**Code type:** Prompt/Response

```pseudo
GIVEN user confirms task extraction
AND action item: "Review proposal by Friday"
WHEN creating task
THEN Claude offers:
  "[l] Linear (Totoro) / [r] Reminder / [s] Skip"
```

---

## Test Suite: Suggestion Mode

### T09.21: Present all suggestions before applying
**Code type:** Prompt/Response

```pseudo
GIVEN enrichment analysis complete
THEN Claude presents summary:
  "**Enrichment suggestions:**
   
   Frontmatter:
   - Add areas: [[domaison]]
   - Add status: active
   
   Links:
   - Jane Smith → [[jane-smith]]
   - domain bundling → [[domain-bundling]]
   
   Tags:
   - Add #pricing, #strategy
   
   [a]pply all / [r]eview each / [c]ancel"
```

### T09.22: Review each suggestion
**Code type:** Prompt/Response

```pseudo
GIVEN user chooses "r" (review each)
THEN Claude presents each suggestion individually:
  "1/6: Add areas: [[domaison]]? [y/n]"
AND applies only approved suggestions
```

### T09.23: Apply all suggestions
**Code type:** Python script

```pseudo
GIVEN user chooses "a" (apply all)
WHEN processing
THEN all suggestions applied in single operation
AND note updated timestamp set
```

---

## Test Suite: Batch Enrichment

### T09.24: Enrich multiple notes
**Code type:** Bash script

```pseudo
GIVEN folder 3_Projects/domain-bundling/ has 5 notes
WHEN executing: claude enrich --folder 3_Projects/domain-bundling/
THEN enrichment runs for each note
AND summary shown at end
```

### T09.25: Skip already-enriched notes
**Code type:** Python script

```pseudo
GIVEN note has frontmatter: enriched: true
AND config.behavior.re_enrich = false
WHEN batch enrichment runs
THEN note skipped
```

---

## Test Suite: Error Handling

### T09.26: Handle invalid frontmatter
**Code type:** Python script

```pseudo
GIVEN note with malformed YAML frontmatter
WHEN attempting enrichment
THEN error: "Cannot parse frontmatter"
AND offers to fix manually
```

### T09.27: Handle missing note
**Code type:** Bash script

```pseudo
GIVEN note path doesn't exist
WHEN executing: claude enrich nonexistent.md
THEN error: "Note not found: nonexistent.md"
AND exit code non-zero
```

### T09.28: Handle read-only file
**Code type:** Python script

```pseudo
GIVEN note file is read-only
WHEN attempting to apply enrichment
THEN error: "Cannot write to file"
AND suggestions saved to pending queue
```

---

## Mock Fixtures

### Note needing enrichment
```yaml
# 0_Inbox/meeting-notes-pricing.md
---
type: capture
source: manual
captured: 2025-01-31T14:00:00+01:00
---

## Pricing Meeting Notes

Met with Jane Smith to discuss domain bundling pricing for Q1.

Key points:
- Need to finalize tier structure by Friday
- Jane will send updated competitor analysis
- Domain Bundling project should track this

Next steps:
- Review proposal
- Schedule follow-up with legal
```
