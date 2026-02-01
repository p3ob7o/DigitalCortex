# Digital Cortex — System Overview

## Vision

Digital Cortex is a personal operating system built on Claude Code and Obsidian. It reduces friction in capturing ideas, tasks, and information while proactively synthesizing inputs from work tools into actionable daily guidance. The system implements PARA for organization and GTD principles for processing, with Claude serving as an intelligent layer that prepares briefs, facilitates reviews, and helps maintain the system.

---

## Core Principles

1. **Frictionless capture** — Any thought, artifact, or external item enters the system with minimal effort
2. **Async processing** — Captures accumulate; Claude processes them on your schedule
3. **Proactive synthesis** — Claude pulls from external sources and prepares actionable briefs
4. **Explicit memory** — All configuration, prompts, and learned preferences are visible and editable
5. **Graceful degradation** — System works offline and tolerates partial failures
6. **Portability** — No hardcoded personal data; configurable for any user

---

## Architecture

```
                          ┌─────────────────────────────────┐
                          │         CAPTURE LAYER           │
                          ├─────────────────────────────────┤
                          │  Share Extension (iOS/macOS)    │
                          │  Quick Capture (tap/shortcut)   │
                          │  Voice Memo (transcribed)       │
                          └───────────────┬─────────────────┘
                                          │
                                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                         OBSIDIAN VAULT                          │
├─────────────────────────────────────────────────────────────────┤
│  0_Inbox/          Daily notes + unprocessed captures           │
│  1_Fleeting/       Processed notes without a home               │
│  2_Drafts/         Work-in-progress posts                       │
│  3_Projects/       Active projects (folders)                    │
│  4_Areas/          Ongoing responsibilities (files)             │
│  5_Resources/      Reference material                           │
│  6_Archive/        Completed/processed items                    │
│  7_Assets/         Linked files                                 │
│  8_People/         Minimal PRM                                  │
│  9_Meta/           Config, prompts, memory                      │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                       CLAUDE CODE LAYER                         │
├─────────────────────────────────────────────────────────────────┤
│  Rituals: Morning Brief, Evening Review, Weekly Review          │
│  Processing: Inbox triage, filing suggestions, task extraction  │
│  Queries: Projects, tasks, people, blocked items                │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                       EXTERNAL SOURCES                          │
├──────────────┬──────────────┬──────────────┬────────────────────┤
│    Gmail     │   Calendar   │    Slack     │        P2          │
│    (API)     │    (API)     │    (MCP)     │       (MCP)        │
├──────────────┼──────────────┴──────────────┴────────────────────┤
│    Linear    │              Apple Reminders                     │
│    (API)     │              (CLI/osascript)                     │
└──────────────┴──────────────────────────────────────────────────┘
```

---

## Feature List

| ID | Feature | Description |
|----|---------|-------------|
| F1 | Vault Structure | Numbered folder hierarchy implementing extended PARA |
| F2 | Capture System | Share extension, quick capture, voice memo |
| F3 | Daily Note Lifecycle | Creation, structure, archival rules |
| F4 | Frontmatter Schemas | Structured metadata for all entity types |
| F5 | Morning Brief (Core) | Daily pull orchestration and synthesis |
| F5.1 | Morning Brief — Gmail | Email integration |
| F5.2 | Morning Brief — Calendar | Calendar integration |
| F5.3 | Morning Brief — Slack | Slack integration |
| F5.4 | Morning Brief — P2 | P2 integration |
| F5.5 | Morning Brief — Linear | Linear integration |
| F5.6 | Morning Brief — Reminders | Reminders integration |
| F6 | Evening Review | Interactive daily reflection and processing |
| F7 | Weekly Review | Projects, fleeting notes, week ahead planning |
| F8 | Inbox Processing | On-demand triage with suggestions |
| F9 | Task Management | Linear + Apple Reminders integration |
| F10 | External Source Integration | Gmail, Calendar, Slack, P2, Linear, Reminders |
| F11 | Command System | Slash commands and natural language |
| F12 | Error Handling | Graceful degradation, offline mode, queuing |
| F13 | Templates & Configuration | Portable prompts with variables |
| F14 | Bootstrap Process | First-run setup and configuration |
| F15 | People (PRM) | Personal relationship management |

---

## Implementation Phases

### Phase 1: Foundation
- F1: Vault Structure
- F14: Bootstrap (basic)
- F13: Templates & Configuration

### Phase 2: Capture & Processing
- F2: Capture System
- F3: Daily Note Lifecycle
- F4: Frontmatter Schemas
- F8: Inbox Processing

### Phase 3: Rituals
- F5: Morning Brief
- F6: Evening Review
- F7: Weekly Review

### Phase 4: Integration
- F10: External Source Integration
- F9: Task Management
- F15: People (PRM)

### Phase 5: Polish
- F11: Command System
- F12: Error Handling & Offline Mode
- F14: Bootstrap (complete)

---

## Documents

- [F1: Vault Structure](./F01-vault-structure.md)
- [F2: Capture System](./F02-capture-system.md)
- [F3: Daily Note Lifecycle](./F03-daily-note-lifecycle.md)
- [F4: Frontmatter Schemas](./F04-frontmatter-schemas.md)
- [F5: Morning Brief (Core)](./F05-morning-brief-core.md)
- [F5.1: Morning Brief — Gmail](./F05.1-gmail.md)
- [F5.2: Morning Brief — Calendar](./F05.2-calendar.md)
- [F5.3: Morning Brief — Slack](./F05.3-slack.md)
- [F5.4: Morning Brief — P2](./F05.4-p2.md)
- [F5.5: Morning Brief — Linear](./F05.5-linear.md)
- [F5.6: Morning Brief — Reminders](./F05.6-reminders.md)
- [F6: Evening Review](./F06-evening-review.md)
- [F7: Weekly Review](./F07-weekly-review.md)
- [F8: Inbox Processing](./F08-inbox-processing.md)
- [F9: Task Management](./F09-task-management.md)
- [F10: External Source Integration](./F10-external-sources.md)
- [F11: Command System](./F11-command-system.md)
- [F12: Error Handling](./F12-error-handling.md)
- [F13: Templates & Configuration](./F13-templates-configuration.md)
- [F14: Bootstrap Process](./F14-bootstrap.md)
- [F15: People (PRM)](./F15-people-prm.md)
