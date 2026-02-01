# T11: Project Management — Tests

## Test Environment

```
test-vault-populated/          ← With 3_Projects/ populated
```

**Mocks:**
- Linear API (for task data)
- User input (interactive flow)

---

## Test Suite: Project Structure

### T11.1: Project folder convention
**Code type:** Bash script

```pseudo
GIVEN project "Domain Bundling"
THEN structure is:
  3_Projects/
  └── domain-bundling/
      ├── domain-bundling.md    # Main project file (same name)
      └── [related files]
```

### T11.2: Project file has required fields
**Code type:** Python script

```pseudo
GIVEN project file domain-bundling.md
THEN frontmatter contains:
  - type: project
  - status: <active|paused|completed|dropped>
  - created: <timestamp>
  - updated: <timestamp>
```

### T11.3: Project file with all optional fields
**Code type:** Python script

```pseudo
GIVEN complete project file
THEN frontmatter may contain:
  - areas: ["[[domaison]]"]
  - linear_project: proj-abc123
  - start: 2025-01-15
  - due: 2025-03-31
  - next_action: "Review pricing proposal"
```

---

## Test Suite: Project Creation

### T11.4: Create project via CLI
**Code type:** Bash script

```pseudo
GIVEN command: claude project create "New Feature Launch"
WHEN executed
THEN creates:
  - 3_Projects/new-feature-launch/
  - 3_Projects/new-feature-launch/new-feature-launch.md
AND project file has status: active
```

### T11.5: Create project via slash command
**Code type:** Prompt/Response

```pseudo
GIVEN user says: "/project new API Integration"
WHEN Claude processes
THEN creates project structure
AND asks for additional details:
  "Project created: API Integration
   Add details?
   - Area: [enter or skip]
   - Due date: [enter or skip]
   - Linear project: [enter or skip]"
```

### T11.6: Project name generates valid folder name
**Code type:** Python script

```pseudo
FOR EACH (name, expected_folder) in:
  ("Domain Bundling", "domain-bundling")
  ("Q1 2025 Goals", "q1-2025-goals")
  ("API v2.0 Launch", "api-v2-0-launch")
WHEN create_project(name)
THEN folder name equals expected_folder
```

### T11.7: Handle duplicate project names
**Code type:** Bash script

```pseudo
GIVEN project "domain-bundling" already exists
WHEN create_project("Domain Bundling")
THEN error: "Project 'domain-bundling' already exists"
AND suggests: "Use different name or update existing project"
```

---

## Test Suite: Status Management

### T11.8: List projects by status
**Code type:** Python script

```pseudo
GIVEN 3 active, 1 paused, 2 completed projects
WHEN list_projects(status="active")
THEN returns 3 active projects
```

### T11.9: Change project status
**Code type:** Python script

```pseudo
GIVEN project with status: active
WHEN update_project_status("domain-bundling", "paused")
THEN project frontmatter status = "paused"
AND updated timestamp refreshed
```

### T11.10: Complete project
**Code type:** Prompt/Response

```pseudo
GIVEN user says: "/project complete domain-bundling"
WHEN Claude processes
THEN asks: "Mark Domain Bundling as complete? [y/n]"
WHEN confirmed
THEN status changed to "completed"
AND offers: "Move to archive? [y/n]"
```

### T11.11: Drop project
**Code type:** Prompt/Response

```pseudo
GIVEN user says: "/project drop stalled-feature"
WHEN Claude processes
THEN asks: "Drop 'Stalled Feature'? This marks it as abandoned. [y/n]"
WHEN confirmed
THEN status changed to "dropped"
```

### T11.12: Pause project
**Code type:** Python script

```pseudo
GIVEN active project
WHEN update_project_status("project-name", "paused")
THEN status = "paused"
AND project excluded from active project lists
```

---

## Test Suite: Linear Integration

### T11.13: Link project to Linear
**Code type:** Python script

```pseudo
GIVEN project without linear_project field
WHEN link_to_linear("domain-bundling", "proj-abc123")
THEN frontmatter updated: linear_project: proj-abc123
```

### T11.14: Fetch Linear progress
**Code type:** Python script

```pseudo
GIVEN project with linear_project: proj-abc123
AND mock Linear returns: 5 total issues, 3 completed
WHEN get_project_progress("domain-bundling")
THEN returns:
  - total: 5
  - completed: 3
  - percentage: 60
```

### T11.15: Show Linear tasks in project view
**Code type:** Prompt/Response

```pseudo
GIVEN user asks: "Show domain-bundling project"
AND project has Linear link
WHEN displaying project
THEN includes:
  "**Linear Progress:** 60% (3/5 tasks)
   
   Open tasks:
   - DOMAIN-456: Update pricing docs (due: Feb 14)
   - DOMAIN-789: Review mockups"
```

### T11.16: Create Linear issue from project context
**Code type:** Prompt/Response

```pseudo
GIVEN viewing project domain-bundling
AND user says: "Add task: Write migration guide"
WHEN creating task
THEN creates in Linear under linked project
AND respects personal team restriction
```

---

## Test Suite: Areas Integration

### T11.17: Link project to areas
**Code type:** Python script

```pseudo
GIVEN project with areas: ["[[domaison]]"]
THEN project appears in domaison area's related projects
```

### T11.18: Add area to project
**Code type:** Python script

```pseudo
GIVEN project without areas
WHEN add_area("domain-bundling", "domaison")
THEN frontmatter areas: ["[[domaison]]"]
```

### T11.19: Multiple areas supported
**Code type:** Python script

```pseudo
GIVEN project touching multiple areas
WHEN setting areas: ["[[domaison]]", "[[jetpack]]"]
THEN both areas linked
AND project shows in both area views
```

---

## Test Suite: Next Action

### T11.20: Set next action
**Code type:** Python script

```pseudo
GIVEN project
WHEN set_next_action("domain-bundling", "Review pricing proposal")
THEN frontmatter next_action: "Review pricing proposal"
```

### T11.21: Clear next action
**Code type:** Python script

```pseudo
GIVEN project with next_action set
WHEN clear_next_action("domain-bundling")
THEN next_action removed from frontmatter
```

### T11.22: Surface next action in brief
**Code type:** Python script

```pseudo
GIVEN active project with next_action set
WHEN generating morning brief priorities
THEN next_action surfaced as potential priority
```

---

## Test Suite: Project Views

### T11.23: List all active projects
**Code type:** Prompt/Response

```pseudo
GIVEN user asks: "Show my projects"
WHEN listing projects
THEN output:
  "**Active Projects (3):**
   1. Domain Bundling — 60% (due: Mar 31) [[domaison]]
   2. BI Phase 1 — 80% (due: Feb 28)
   3. Jetpack Update — 20% (no due date)
   
   **Paused (1):**
   - Experimental Feature"
```

### T11.24: Show single project details
**Code type:** Prompt/Response

```pseudo
GIVEN user asks: "Show domain-bundling"
WHEN displaying project
THEN includes:
  - Status and dates
  - Area links
  - Linear progress
  - Next action
  - Recent activity (files modified)
  - Related people
```

### T11.25: Show stalled projects warning
**Code type:** Python script

```pseudo
GIVEN project with no activity for 14+ days
AND status is still "active"
WHEN listing projects
THEN project flagged: "⚠ No activity for 14 days"
```

---

## Test Suite: File Management

### T11.26: File note to project
**Code type:** Python script

```pseudo
GIVEN note in 0_Inbox/
WHEN file_to_project(note, "domain-bundling")
THEN note moved to 3_Projects/domain-bundling/
AND note frontmatter updated with project link
```

### T11.27: List project files
**Code type:** Python script

```pseudo
GIVEN project folder with 5 files
WHEN list_project_files("domain-bundling")
THEN returns all 5 files with metadata
```

### T11.28: Project file search
**Code type:** Prompt/Response

```pseudo
GIVEN user asks: "Find pricing notes in domain-bundling"
WHEN searching project
THEN returns files matching "pricing" in title or content
```

---

## Test Suite: Archival

### T11.29: Archive completed project
**Code type:** Python script

```pseudo
GIVEN project with status: completed
AND user confirms archive
WHEN archive_project("domain-bundling")
THEN entire folder moved to 6_Archive/Projects/domain-bundling/
```

### T11.30: Preserve project structure in archive
**Code type:** Python script

```pseudo
GIVEN project folder with subfolders and files
WHEN archiving
THEN entire structure preserved in archive
```

---

## Test Suite: Error Handling

### T11.31: Handle missing project
**Code type:** Bash script

```pseudo
GIVEN project "nonexistent" doesn't exist
WHEN show_project("nonexistent")
THEN error: "Project not found: nonexistent"
AND suggests similar project names if any
```

### T11.32: Handle invalid status
**Code type:** Python script

```pseudo
GIVEN attempt to set status: "invalid-status"
WHEN update_project_status()
THEN error: "Invalid status. Use: active, paused, completed, dropped"
```

---

## Mock Fixtures

### Project structure
```
test-vault-populated/3_Projects/
├── domain-bundling/
│   ├── domain-bundling.md
│   ├── pricing-analysis.md
│   └── meeting-notes/
│       └── kickoff-meeting.md
├── bi-phase-1/
│   └── bi-phase-1.md
└── stalled-project/
    └── stalled-project.md
```

### Project file
```yaml
# domain-bundling/domain-bundling.md
---
type: project
status: active
areas: ["[[domaison]]"]
linear_project: proj-abc123
start: 2025-01-15
due: 2025-03-31
next_action: Review pricing proposal
created: 2025-01-15T10:00:00+01:00
updated: 2025-01-30T16:00:00+01:00
---

## Overview

Domain bundling project for Q1 2025.

## Goals

- Launch bundled pricing by March
- Partner integration with Verisign

## Related

- [[jane-smith]] — Verisign contact
- [[pricing-analysis]]
```
