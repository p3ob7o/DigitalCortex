# F11: Command System

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F11 |
| Priority | Phase 5 (Polish) |
| Dependencies | All feature implementations |
| Dependents | None |

## Purpose

Provide consistent invocation methods for all system operations. Users can invoke commands via CLI arguments, slash commands in session, or natural language—all are equivalent.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F11.1 | Three equivalent invocation patterns | Must |
| F11.2 | Commands work mid-conversation | Must |
| F11.3 | Output to terminal by default | Must |
| F11.4 | Output to Obsidian on explicit request | Must |
| F11.5 | Commands are discoverable via /help | Must |
| F11.6 | Natural language maps to commands | Should |

---

## Invocation Patterns

Every command supports three equivalent invocation methods:

### 1. CLI Argument

```bash
claude brief
claude review
claude process
claude task "Update documentation"
```

### 2. Slash Command in Session

```
> claude

You: /brief
Claude: [runs morning brief]

You: /task Update documentation
Claude: [creates task]
```

### 3. Natural Language

```
You: Let's do the morning brief
Claude: [runs morning brief]

You: I need to remember to update the documentation
Claude: Is this a task (needs dedicated time) or a reminder (quick)?
```

---

## Command Reference

### Ritual Commands

| Command | Aliases | Description | Feature |
|---------|---------|-------------|---------|
| `/brief` | `/morning`, `/am` | Run morning brief | F5 |
| `/review` | `/evening`, `/pm` | Run evening review | F6 |
| `/weekly` | `/week` | Run weekly review | F7 |
| `/process` | `/inbox` | Process inbox items | F8 |

### Capture Commands

| Command | Description | Feature |
|---------|-------------|---------|
| `/capture <text>` | Quick capture to daily note | F2 |
| `/task <text>` | Create task in Linear (Totoro) | F9 |
| `/reminder <text>` | Create reminder | F9 |
| `/shopping <text>` | Add to Shopping list | F9 |

### Query Commands

| Command | Description | Feature |
|---------|-------------|---------|
| `/today` | Show today's schedule and tasks | F5 |
| `/tasks` | Show open tasks assigned to me | F9 |
| `/projects` | Show active projects with status | F4 |
| `/blocked` | Show blocked projects/tasks | F4 |
| `/people <name>` | Show person context | F15 |

### System Commands

| Command | Description | Feature |
|---------|-------------|---------|
| `/status` | Show system health, last sync times | F12 |
| `/sync` | Force refresh from all sources | F10 |
| `/help` | List available commands | F11 |

---

## Command Syntax

### Basic Commands

```
/command
```

Runs the command with defaults.

### Commands with Arguments

```
/command argument text here
```

Everything after the command name is the argument.

### Commands with Flags

```
/projects --save
/tasks --due today
```

Flags modify command behavior.

---

## Natural Language Mapping

Claude recognizes intent and maps to commands:

| Natural Language | Mapped Command |
|------------------|----------------|
| "Let's do the morning brief" | `/brief` |
| "Start my day" | `/brief` |
| "What's on today?" | `/today` |
| "Evening review time" | `/review` |
| "Let's process the inbox" | `/process` |
| "Show me my tasks" | `/tasks` |
| "What projects are blocked?" | `/blocked` |
| "I need to buy milk" | `/shopping milk` |
| "Remind me to call Jane" | `/reminder call Jane` |
| "Create a task to update docs" | `/task update docs` |

---

## Output Behavior

### Default: Terminal Only

Commands output to the terminal for immediate reading. Nothing is written to Obsidian unless the command's nature requires it (e.g., `/brief` writes to daily note).

### Explicit Save

Add `--save` flag to write output to Obsidian:

```
/projects --save
```

Creates or updates a dashboard file.

### Interactive Prompts

Some commands prompt for confirmation:

```
/task Update documentation

Creating in Linear (Totoro):
  Title: Update documentation
  Project: (none)
  Due: (none)
  
  [c] Create
  [p] Add project
  [d] Add due date
  [e] Edit all
```

---

## Mid-Conversation Commands

Commands work at any point in a conversation:

```
You: I'm thinking about the domain-bundling project...

Claude: What aspects are you considering?

You: /people Jane

Claude: Jane Smith (Verisign)
        Partner Manager
        Last contact: January 28
        Areas: Domaison
        
        Recent: Discussed Q1 transfer pricing
        
You: Right, I should follow up with her.

Claude: Would you like to create a reminder to follow up?
```

The conversation context is preserved.

---

## Help Output

```
/help

DIGITAL CORTEX COMMANDS

Rituals
  /brief, /morning, /am     Morning brief
  /review, /evening, /pm    Evening review  
  /weekly, /week            Weekly review
  /process, /inbox          Process inbox

Capture
  /capture <text>           Quick capture to daily note
  /task <text>              Create task in Linear
  /reminder <text>          Create reminder
  /shopping <text>          Add to shopping list

Query
  /today                    Today's schedule + tasks
  /tasks                    Open tasks assigned to me
  /projects                 Active projects with status
  /blocked                  Blocked projects/tasks
  /people <name>            Person context

System
  /status                   System health
  /sync                     Force refresh sources
  /help                     This help message

Commands also work as natural language.
Example: "Let's do the morning brief" = /brief
```

---

## Error Handling

### Unknown Command

```
/foo

Unknown command: /foo
Did you mean: /process?

Type /help for available commands.
```

### Missing Argument

```
/task

/task requires text.
Usage: /task <description>

Example: /task Update pricing documentation
```

### Command Failed

```
/sync

Syncing sources...
  Gmail: ✓
  Calendar: ✓
  Slack: ✗ MCP unavailable
  Linear: ✓
  
Some sources failed. Run /status for details.
```

---

## Command Registration

Commands are registered in `9_Meta/commands.yaml`:

```yaml
commands:
  - name: brief
    aliases: [morning, am]
    description: Run morning brief
    feature: F5
    mode: suggestion
    
  - name: review
    aliases: [evening, pm]
    description: Run evening review
    feature: F6
    mode: interactive
    
  - name: task
    description: Create task in Linear
    feature: F9
    requires_argument: true
    argument_name: text
```

This allows the command system to be extended without code changes.

---

## Validation

| Check | Expected |
|-------|----------|
| All three invocation patterns work | ✓ |
| Commands work mid-conversation | ✓ |
| Natural language maps correctly | ✓ |
| /help lists all commands | ✓ |
| Unknown commands show suggestions | ✓ |
| Arguments parsed correctly | ✓ |

---

## Related Features

- All features are invoked via commands
- **F12 (Error Handling)**: Command failure behavior
- **F13 (Templates)**: Commands reference templates
