# T02: Capture System — Tests

## Test Environment

```
test-vault-populated/          ← Pre-populated vault with today's daily note
```

**Mocks:**
- Transcription service: Returns predefined text for audio files
- System clock: Fixed to 2025-01-31T14:30:00+01:00

---

## Test Suite: Quick Capture (Short Text)

### T02.1: Short text appends to daily note Captures section
**Code type:** Bash script

```pseudo
GIVEN test-vault-populated/ with today's daily note (2025-01-31 Friday.md)
AND daily note has empty ## Captures section
WHEN quick_capture("Quick thought about pricing") is executed
THEN daily note ## Captures section contains:
  - timestamp (14:30)
  - "Quick thought about pricing"
AND no new file is created in 0_Inbox/
```

### T02.2: Quick capture includes timestamp
**Code type:** Bash script

```pseudo
GIVEN mock clock set to 2025-01-31T14:30:00+01:00
WHEN quick_capture("Test capture") is executed
THEN captured text is preceded by "### 14:30" or similar time marker
```

### T02.3: Multiple captures append in chronological order
**Code type:** Bash script

```pseudo
GIVEN mock clock starts at 14:30
WHEN quick_capture("First thought") at 14:30
AND quick_capture("Second thought") at 14:45
AND quick_capture("Third thought") at 15:00
THEN ## Captures section contains all three in order:
  - 14:30: First thought
  - 14:45: Second thought
  - 15:00: Third thought
```

### T02.4: Quick capture creates daily note if missing
**Code type:** Bash script

```pseudo
GIVEN test vault with NO daily note for today
WHEN quick_capture("Test capture") is executed
THEN 0_Inbox/2025-01-31 Friday.md is created
AND file has correct frontmatter (type: daily, date: 2025-01-31)
AND ## Captures section contains "Test capture"
```

### T02.5: Quick capture updates frontmatter 'updated' timestamp
**Code type:** Python script

```pseudo
GIVEN daily note with updated: 2025-01-31T08:00:00+01:00
WHEN quick_capture("Test") at 14:30
THEN frontmatter updated field equals 2025-01-31T14:30:00+01:00
```

---

## Test Suite: Share Extension Capture (Artifacts)

### T02.6: Slack share creates separate file
**Code type:** Python script

```pseudo
GIVEN share payload:
  {
    "source": "slack",
    "channel": "#domain-strategy",
    "from": "@colleague",
    "url": "https://automattic.slack.com/archives/C123/p456",
    "content": "Long message content exceeding threshold..."
  }
WHEN share_capture(payload) is executed
THEN new file created in 0_Inbox/ with name pattern: slack-*.md
AND file frontmatter contains:
  - type: capture
  - source: slack
  - channel: #domain-strategy
  - from: @colleague
  - url: https://automattic.slack.com/archives/C123/p456
  - captured: 2025-01-31T14:30:00+01:00
AND file body contains "Long message content..."
```

### T02.7: Email share includes sender and subject
**Code type:** Python script

```pseudo
GIVEN share payload:
  {
    "source": "email",
    "from": "jane@verisign.com",
    "subject": "RE: Pricing Discussion",
    "content": "Email body..."
  }
WHEN share_capture(payload) is executed
THEN new file frontmatter contains:
  - source: email
  - from: jane@verisign.com
  - subject: RE: Pricing Discussion
```

### T02.8: Web highlight includes URL and title
**Code type:** Python script

```pseudo
GIVEN share payload:
  {
    "source": "web",
    "url": "https://example.com/article",
    "title": "Article Title",
    "content": "Highlighted text..."
  }
WHEN share_capture(payload) is executed
THEN new file frontmatter contains:
  - source: web
  - url: https://example.com/article
  - title: Article Title
```

### T02.9: Share capture links from daily note
**Code type:** Python script

```pseudo
GIVEN share capture creates file: slack-domain-discussion.md
THEN daily note ## Captures section contains:
  - "[[slack-domain-discussion]]" or "![[slack-domain-discussion]]"
```

---

## Test Suite: Voice Memo Capture

### T02.10: Voice memo transcribes and saves
**Code type:** Python script

```pseudo
GIVEN mock transcription service returns: "Transcribed voice content"
AND audio file: test-audio.m4a
WHEN voice_capture(test-audio.m4a) is executed
THEN new file created in 0_Inbox/ with name pattern: voice-memo-*.md
AND file body contains "Transcribed voice content"
```

### T02.11: Voice memo frontmatter includes metadata
**Code type:** Python script

```pseudo
GIVEN voice capture executed successfully
THEN file frontmatter contains:
  - type: capture
  - source: voice-memo
  - captured: <ISO timestamp>
  - duration: <duration in seconds or MM:SS>
  - transcription_service: cloud | local
```

### T02.12: Voice memo falls back to local transcription
**Code type:** Python script

```pseudo
GIVEN mock cloud transcription fails (simulated network error)
AND mock local transcription returns: "Local transcription result"
WHEN voice_capture(test-audio.m4a) is executed
THEN file is created successfully
AND frontmatter transcription_service equals "local"
AND body contains "Local transcription result"
```

### T02.13: Voice memo links from daily note
**Code type:** Python script

```pseudo
GIVEN voice capture creates file: voice-memo-2025-01-31-1430.md
THEN daily note ## Captures section contains link to voice memo file
```

---

## Test Suite: Capture Routing Logic

### T02.14: Short text (under threshold) goes inline
**Code type:** Python script

```pseudo
GIVEN capture text is 50 characters (under threshold)
WHEN capture_route(text) is evaluated
THEN returns route: "inline" (append to daily note)
```

### T02.15: Long text (over threshold) creates file
**Code type:** Python script

```pseudo
GIVEN capture text is 500 characters (over threshold)
WHEN capture_route(text) is evaluated
THEN returns route: "file" (create separate file)
```

### T02.16: Artifact source always creates file
**Code type:** Python script

```pseudo
GIVEN capture with source: "slack" and short text (50 chars)
WHEN capture_route(payload) is evaluated
THEN returns route: "file" regardless of text length
```

---

## Test Suite: Filename Generation

### T02.17: Filename is filesystem-safe
**Code type:** Python script

```pseudo
GIVEN share payload with title: "Article: \"Quotes\" & <Special> Chars!"
WHEN generate_capture_filename(payload) is executed
THEN filename contains no: " / \ : * ? " < > |
AND filename is valid on macOS, Linux, and Windows
```

### T02.18: Filename includes source prefix
**Code type:** Python script

```pseudo
FOR EACH source in [slack, email, web, voice-memo]:
  GIVEN capture with source: $source
  WHEN generate_capture_filename(payload)
  THEN filename starts with: $source-
```

### T02.19: Filename includes timestamp for uniqueness
**Code type:** Python script

```pseudo
GIVEN two captures at same second with same source
WHEN generating filenames for both
THEN filenames are unique (include milliseconds or counter)
```

---

## Test Suite: Frontmatter Validation

### T02.20: All captures have required fields
**Code type:** Python script

```pseudo
FOR EACH capture type in [slack, email, web, voice-memo]:
  GIVEN capture of type $type
  WHEN capture is saved
  THEN frontmatter includes:
    - type: capture
    - source: $type
    - captured: <ISO 8601 with timezone>
    - created: <ISO 8601 with timezone>
    - updated: <ISO 8601 with timezone>
```

### T02.21: Timestamps include timezone
**Code type:** Python script

```pseudo
GIVEN any capture
WHEN examining captured, created, updated fields
THEN all timestamps match pattern: \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}
```

---

## Test Suite: Error Handling

### T02.22: Handle missing daily note gracefully
**Code type:** Bash script

```pseudo
GIVEN 0_Inbox/ exists but has no daily note
WHEN quick_capture("Test") is executed
THEN daily note is created first
AND capture is appended
AND exit code is 0
```

### T02.23: Handle vault not found
**Code type:** Bash script

```pseudo
GIVEN VAULT_PATH points to nonexistent directory
WHEN quick_capture("Test") is executed
THEN exit code is non-zero
AND stderr contains "vault" and "not found" or similar
```

### T02.24: Handle transcription service failure
**Code type:** Python script

```pseudo
GIVEN both cloud and local transcription fail
WHEN voice_capture(audio.m4a) is executed
THEN exit code is non-zero
AND error message indicates transcription failure
AND no corrupt file is created
```

---

## Test Fixtures Required

### test-vault-populated/0_Inbox/2025-01-31 Friday.md
```markdown
---
type: daily
date: 2025-01-31
processed: false
review_completed: false
created: 2025-01-31T07:00:00+01:00
updated: 2025-01-31T07:00:00+01:00
---

## Morning Brief

---

## Captures

---

## Evening Review

```

### Mock: Transcription Service
```pseudo
mock_transcription_service:
  cloud:
    success: returns "Cloud transcribed: {audio_content_hash}"
    failure: raises NetworkError
  local:
    success: returns "Local transcribed: {audio_content_hash}"
    failure: raises TranscriptionError
```
