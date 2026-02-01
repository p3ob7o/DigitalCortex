# F2: Capture System

## Overview

| Attribute | Value |
|-----------|-------|
| Feature ID | F2 |
| Priority | Phase 2 (Capture & Processing) |
| Dependencies | F1 (Vault Structure), F3 (Daily Note) |
| Dependents | F5, F6, F7, F8 (all processing features) |

## Purpose

Enable frictionless capture of thoughts, artifacts, and external items through three input modes, each optimized for a specific context. All captures land in the inbox for later processing.

---

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| F2.1 | Share extension captures URL, text, metadata from any iOS/macOS app | Must |
| F2.2 | Quick capture available via single tap (iOS) or keyboard shortcut (macOS) | Must |
| F2.3 | Voice memo records audio and transcribes to text | Must |
| F2.4 | Transcription uses cloud service with local fallback for offline | Must |
| F2.5 | Short text captures append to today's daily note | Must |
| F2.6 | Artifacts and longer content become separate files in 0_Inbox | Must |
| F2.7 | All captured files are linked from today's daily note | Must |
| F2.8 | Captures include timestamp and source metadata | Must |

---

## Input Modes

| Mode | Input | Trigger | Platform | Output |
|------|-------|---------|----------|--------|
| Share Extension | URL, text, metadata | Share sheet | iOS + macOS | Formatted inbox item |
| Quick Capture | Raw text | Tap / shortcut | iOS + macOS | Append to daily note |
| Voice Memo | Audio | Tap | iOS | Transcribed text → inbox |

---

## Capture Flow

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Share Sheet    │    │  Quick Capture  │    │  Voice Memo     │
│  (iOS/macOS)    │    │  (tap/shortcut) │    │  (iOS)          │
└────────┬────────┘    └────────┬────────┘    └────────┬────────┘
         │                      │                      │
         │                      │                      ▼
         │                      │             ┌───────────────────┐
         │                      │             │ Transcription     │
         │                      │             │ (cloud + fallback)│
         │                      │             └────────┬──────────┘
         │                      │                      │
         ▼                      ▼                      ▼
    ┌────────────────────────────────────────────────────────┐
    │                      ROUTING                           │
    │                                                        │
    │  Short text (<threshold)?  →  Append to daily note     │
    │  Artifact or longer?       →  Create inbox file        │
    └────────────────────────────────────────────────────────┘
                               │
                               ▼
                        ┌─────────────┐
                        │   0_Inbox   │
                        └─────────────┘
```

---

## File Formats

### Short capture (appended to daily note)

```markdown
### 14:23
Quick thought about transfer pricing UX
```

### Share extension capture (separate file)

```markdown
---
captured: 2025-01-31T14:23:00+01:00
source: slack
channel: "#domain-strategy"
from: "@colleague"
url: https://slack.com/archives/...
created: 2025-01-31T14:23:00+01:00
updated: 2025-01-31T14:23:00+01:00
---

The actual message or quote content goes here.

Context from the conversation if available.
```

### Voice memo (transcribed)

```markdown
---
captured: 2025-01-31T14:30:00+01:00
source: voice-memo
duration: 45s
transcription_service: cloud | local
created: 2025-01-31T14:30:00+01:00
updated: 2025-01-31T14:30:00+01:00
---

Transcribed content from the voice memo goes here.
```

### Web highlight

```markdown
---
captured: 2025-01-31T15:00:00+01:00
source: web
url: https://example.com/article
title: "Article Title"
created: 2025-01-31T15:00:00+01:00
updated: 2025-01-31T15:00:00+01:00
---

> Highlighted text from the webpage.

My annotation or thought about this.
```

---

## Transcription

### Cloud Service (Primary)
- Higher accuracy for technical terms
- Speaker identification possible
- Requires network connectivity

### Local Fallback (Whisper/iOS Native)
- Works offline (airplane mode)
- Acceptable accuracy for most content
- Processes on-device

### Selection Logic

```
if network_available:
    use cloud_transcription
else:
    use local_transcription
    
mark transcription_service in frontmatter
```

---

## Daily Note Integration

When a capture occurs, the daily note is updated:

```markdown
## Captures

### 09:15
Quick thought about transfer pricing UX

### 11:42
![[slack-thread-legal-approval.md]]

### 14:30
![[voice-memo-2025-01-31-1430.md]]
```

Short captures are inline. File captures are linked using Obsidian's `![[]]` syntax.

---

## Filename Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Slack thread | `slack-{summary}.md` | `slack-thread-legal-approval.md` |
| Voice memo | `voice-memo-{timestamp}.md` | `voice-memo-2025-01-31-1430.md` |
| Web highlight | `web-{domain}-{summary}.md` | `web-example-pricing-article.md` |
| Email | `email-{sender}-{subject}.md` | `email-jane-pricing-approval.md` |
| Screenshot | `screenshot-{timestamp}.png` | `screenshot-2025-01-31-1430.png` |

---

## Implementation Notes

### Share Extension (iOS/macOS)
- Requires native app or Shortcuts integration
- Must handle various input types (URL, text, image)
- Should extract metadata where possible

### Quick Capture
- iOS: Widget, Shortcut, or dedicated app
- macOS: Global keyboard shortcut (e.g., ⌘⇧C)
- Must be fast (<1 second to input ready)

### Voice Memo
- iOS: Dedicated recording interface
- Auto-start transcription on stop
- Store original audio in 7_Assets if desired

---

## Validation

| Check | Expected |
|-------|----------|
| Share extension creates properly formatted file | ✓ |
| Quick capture appends to correct daily note | ✓ |
| Voice memo transcribes and creates file | ✓ |
| Offline transcription works | ✓ |
| All captures have correct frontmatter | ✓ |
| Links appear in daily note | ✓ |

---

## Related Features

- **F3 (Daily Note)**: Receives short captures, links to files
- **F8 (Inbox Processing)**: Processes captured items
- **F12 (Error Handling)**: Offline transcription fallback
