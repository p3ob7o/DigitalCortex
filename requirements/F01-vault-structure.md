# F1: Vault Structure & Scaffolding

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F1 |
| Priority | Phase 1 (Foundation) |
| Dependencies | None |
| Dependents | All other features |

## Purpose

Establish the physical organization of the Obsidian vault using numbered folders that implement an extended PARA method. This structure provides a predictable, scannable foundation for all other system operations.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F1.1 | Vault contains 10 top-level folders, numbered 0-9 for sort order | Must |
| F1.2 | Folder names follow convention: `N_Name` | Must |
| F1.3 | 6_Archive contains Daily-Notes subfolder with YYYY/MM structure | Must |
| F1.4 | 9_Meta contains prompts/, config.yaml, memory.md, pending.json | Must |
| F1.5 | .claude/ folder at vault root for Claude Code native config | Must |
| F1.6 | Folder structure is created during bootstrap if missing | Must |

---

## Folder Structure

```
Vault/
├── .claude/                         ← Claude Code native config
├── 0_Inbox/                         ← Daily notes + unprocessed captures
├── 1_Fleeting/                      ← Processed notes without a home yet
├── 2_Drafts/                        ← Work-in-progress posts (folders)
├── 3_Projects/                      ← Active projects (folders with index)
├── 4_Areas/                         ← Ongoing responsibilities (files)
├── 5_Resources/                     ← Reference material
├── 6_Archive/
│   └── Daily-Notes/
│       └── YYYY/
│           └── MM/                  ← Processed daily notes
├── 7_Assets/                        ← Linked files (images, PDFs, etc.)
├── 8_People/                        ← Minimal PRM, one file per person
└── 9_Meta/
    ├── prompts/
    │   ├── morning-brief.md
    │   ├── evening-review.md
    │   ├── weekly-review.md
    │   └── process-inbox.md
    ├── config.yaml
    ├── memory.md
    ├── pending.json
    └── sources.yaml
```

---

## Folder Definitions

| Folder | Purpose | Content Type |
|--------|---------|--------------|
| 0_Inbox | Capture landing zone | Daily notes, unprocessed items |
| 1_Fleeting | Processed but unplaced | Ideas needing development |
| 2_Drafts | Work-in-progress writing | Subfolders per draft with assets |
| 3_Projects | Active projects | Subfolders with index file |
| 4_Areas | Ongoing responsibilities | Single markdown files |
| 5_Resources | Reference material | Files and folders |
| 6_Archive | Completed/processed | Daily notes, finished projects |
| 7_Assets | Binary attachments | Images, PDFs, downloads |
| 8_People | Contact records | One markdown file per person |
| 9_Meta | System configuration | Config, prompts, state |

---

## Design Decisions

### Why numbered prefixes?

Obsidian and most file browsers sort alphabetically by default. Numbered prefixes ensure folders appear in a logical workflow order (capture → process → organize → archive) rather than alphabetically (Archive, Areas, Assets...).

### Why extended PARA?

Classic PARA (Projects, Areas, Resources, Archive) doesn't account for:
- Inbox (GTD capture requirement)
- Fleeting notes (ideas not ready for projects)
- Drafts (a specific workflow for publishing)
- Assets (binary files need a home)
- People (relationships as a first-class entity)
- Meta (system configuration)

### Why folders vs. tags?

Folders provide physical separation, easier backup/sync, and work with any tool. Tags are Obsidian-specific. The system uses both: folders for primary organization, tags for cross-cutting concerns.

---

## Validation

| Check | Expected |
|-------|----------|
| All 10 top-level folders exist | ✓ |
| 6_Archive/Daily-Notes/ exists | ✓ |
| 9_Meta/prompts/ contains all templates | ✓ |
| 9_Meta/config.yaml exists and is valid | ✓ |
| .claude/ folder exists | ✓ |

---

## Related Features

- **F14 (Bootstrap)**: Creates this structure on first run
- **F3 (Daily Note Lifecycle)**: Uses 0_Inbox and 6_Archive
- **F13 (Templates)**: Populates 9_Meta/prompts/
