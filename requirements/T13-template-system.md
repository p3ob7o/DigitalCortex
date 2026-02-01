# T13: Template System — Tests

## Test Environment

```
test-vault-populated/          ← With 9_Meta/prompts/ populated
```

**Mocks:**
- System clock
- User input

---

## Test Suite: Template Structure

### T13.1: Prompt templates exist after scaffold
**Code type:** Bash script

```pseudo
GIVEN scaffold_vault() executed
THEN the following templates exist:
  - 9_Meta/prompts/morning-brief.md
  - 9_Meta/prompts/evening-review.md
  - 9_Meta/prompts/weekly-review.md
  - 9_Meta/prompts/process-inbox.md
```

### T13.2: Template has valid frontmatter
**Code type:** Python script

```pseudo
GIVEN template file morning-brief.md
THEN frontmatter contains:
  - name: "Morning Brief"
  - mode: suggestion | interactive
  - triggers: [list of trigger commands]
```

### T13.3: Template has instruction body
**Code type:** Python script

```pseudo
GIVEN template file
THEN body contains markdown instructions for Claude
AND may include variable placeholders: {{variable_name}}
```

---

## Test Suite: Template Loading

### T13.4: Load template by name
**Code type:** Python script

```pseudo
GIVEN template morning-brief.md exists
WHEN load_template("morning-brief")
THEN returns template object with:
  - frontmatter parsed
  - body content
```

### T13.5: Load template by trigger
**Code type:** Python script

```pseudo
GIVEN morning-brief.md has triggers: ["/brief", "/morning"]
WHEN find_template_by_trigger("/brief")
THEN returns morning-brief template
```

### T13.6: Handle missing template
**Code type:** Python script

```pseudo
GIVEN template "nonexistent.md" doesn't exist
WHEN load_template("nonexistent")
THEN returns null or raises TemplateNotFound error
```

---

## Test Suite: Variable Substitution

### T13.7: Substitute date variables
**Code type:** Python script

```pseudo
GIVEN template with: "Today is {{date}}"
AND mock date is 2025-01-31
WHEN render_template(template)
THEN output: "Today is 2025-01-31"
```

### T13.8: Substitute time variables
**Code type:** Python script

```pseudo
GIVEN template with: "Current time: {{time}}"
AND mock time is 08:30
WHEN render_template(template)
THEN output: "Current time: 08:30"
```

### T13.9: Substitute day variables
**Code type:** Python script

```pseudo
GIVEN template with: "Happy {{weekday}}!"
AND mock date is Friday
WHEN render_template(template)
THEN output: "Happy Friday!"
```

### T13.10: Substitute vault path variables
**Code type:** Python script

```pseudo
GIVEN template with: "Inbox: {{vault.inbox_path}}"
WHEN render_template(template)
THEN output: "Inbox: /path/to/vault/0_Inbox"
```

### T13.11: Substitute user name variable
**Code type:** Python script

```pseudo
GIVEN template with: "Good morning, {{user.name}}!"
AND config has user.name: "Paolo"
WHEN render_template(template)
THEN output: "Good morning, Paolo!"
```

### T13.12: Handle missing variable
**Code type:** Python script

```pseudo
GIVEN template with: "Value: {{undefined_var}}"
WHEN render_template(template)
THEN output: "Value: {{undefined_var}}" (preserved)
OR output: "Value: " (empty string)
AND warning logged
```

---

## Test Suite: Mode Handling

### T13.13: Suggestion mode template
**Code type:** Python script

```pseudo
GIVEN template with mode: suggestion
WHEN executing workflow from template
THEN Claude prepares suggestions
AND waits for user approval before actions
```

### T13.14: Interactive mode template
**Code type:** Python script

```pseudo
GIVEN template with mode: interactive
WHEN executing workflow from template
THEN Claude prompts for each decision
AND waits for user input throughout
```

---

## Test Suite: Custom Templates

### T13.15: Create custom template
**Code type:** Bash script

```pseudo
GIVEN user creates 9_Meta/prompts/standup-notes.md with:
  ---
  name: Standup Notes
  mode: suggestion
  triggers: ["/standup"]
  ---
  Generate standup notes...
THEN template is recognized by system
AND /standup trigger works
```

### T13.16: Override default template
**Code type:** Python script

```pseudo
GIVEN user modifies 9_Meta/prompts/morning-brief.md
WHEN loading template
THEN user's modified version is used
AND original behavior updated
```

### T13.17: Validate custom template
**Code type:** Python script

```pseudo
GIVEN custom template with missing required frontmatter
WHEN validate_template(template)
THEN returns validation errors:
  - "Missing required field: mode"
```

---

## Test Suite: Template Discovery

### T13.18: List all templates
**Code type:** Python script

```pseudo
GIVEN 4 default templates + 1 custom template
WHEN list_templates()
THEN returns 5 templates with metadata
```

### T13.19: List triggers
**Code type:** Python script

```pseudo
GIVEN templates with various triggers
WHEN list_triggers()
THEN returns mapping:
  /brief → morning-brief
  /morning → morning-brief
  /review → evening-review
  /weekly → weekly-review
  /process → process-inbox
  /inbox → process-inbox
```

### T13.20: Detect trigger conflicts
**Code type:** Python script

```pseudo
GIVEN two templates both claim trigger: /test
WHEN validating templates
THEN warning: "Trigger conflict: /test claimed by template-a and template-b"
```

---

## Test Suite: Template Inheritance

### T13.21: Base template support
**Code type:** Python script

```pseudo
GIVEN template with: extends: base-workflow
AND base-workflow.md exists
WHEN loading template
THEN inherits base settings
AND overrides with specific settings
```

### T13.22: Include partial templates
**Code type:** Python script

```pseudo
GIVEN template with: {{include:common-instructions}}
AND 9_Meta/prompts/partials/common-instructions.md exists
WHEN rendering template
THEN partial content included
```

---

## Test Suite: Note Templates

### T13.23: Daily note template
**Code type:** Python script

```pseudo
GIVEN templates/daily-note.md defines daily note structure
WHEN create_daily_note()
THEN note created using template structure
```

### T13.24: Project note template
**Code type:** Python script

```pseudo
GIVEN templates/project.md defines project structure
WHEN create_project("New Project")
THEN project file created using template
```

### T13.25: Person template
**Code type:** Python script

```pseudo
GIVEN templates/person.md defines person structure
WHEN creating person file
THEN file created using template
```

---

## Test Suite: Error Handling

### T13.26: Handle invalid YAML frontmatter
**Code type:** Python script

```pseudo
GIVEN template with malformed YAML
WHEN loading template
THEN error: "Invalid YAML in template: morning-brief.md"
AND template not loaded
```

### T13.27: Handle circular includes
**Code type:** Python script

```pseudo
GIVEN template-a includes template-b
AND template-b includes template-a
WHEN loading template-a
THEN error: "Circular include detected"
AND prevents infinite loop
```

### T13.28: Handle missing partials
**Code type:** Python script

```pseudo
GIVEN template with: {{include:nonexistent}}
WHEN rendering template
THEN warning: "Partial not found: nonexistent"
AND placeholder preserved or removed
```

---

## Mock Fixtures

### morning-brief.md template
```markdown
---
name: Morning Brief
mode: suggestion
triggers:
  - /brief
  - /morning
  - /am
sources:
  - gmail
  - calendar
  - slack
  - p2
  - linear
  - reminders
output_sections:
  - calendar
  - completed
  - emails
  - slack_p2
  - tasks
  - priorities
  - decisions
---

# Morning Brief Instructions

Generate a morning brief for {{user.name}} on {{weekday}}, {{date}}.

## Behavior

1. Fetch data from all enabled sources since {{state.last_brief}}
2. Synthesize into unified brief
3. Present for approval before writing

## Output Format

Write to today's daily note under ## Morning Brief section.

{{include:common-output-format}}
```

### Custom template example
```markdown
---
name: Standup Notes
mode: suggestion
triggers:
  - /standup
---

# Standup Notes

Generate standup notes based on:
- Yesterday's completions
- Today's calendar
- Current priorities

Format as:
- What I did yesterday
- What I'm doing today
- Blockers
```
