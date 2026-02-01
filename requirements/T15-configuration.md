# T15: Configuration — Tests

## Test Environment

```
test-vault-populated/          ← With 9_Meta/config.yaml
```

**Mocks:**
- Environment variables
- System timezone

---

## Test Suite: Config File Structure

### T15.1: Config file exists after scaffold
**Code type:** Bash script

```pseudo
GIVEN scaffold_vault() executed
THEN 9_Meta/config.yaml exists
AND file is valid YAML
```

### T15.2: Config has required sections
**Code type:** Python script

```pseudo
GIVEN 9_Meta/config.yaml
THEN config contains top-level keys:
  - user
  - sources
  - vault
  - behavior
```

### T15.3: All sections have defaults
**Code type:** Python script

```pseudo
GIVEN freshly scaffolded config
THEN all required fields have default values
AND system can operate without user edits
```

---

## Test Suite: User Configuration

### T15.4: User section structure
**Code type:** Python script

```pseudo
GIVEN config.user section
THEN contains:
  - name: <string>
  - email: <email>
  - timezone: <IANA timezone>
```

### T15.5: Validate timezone format
**Code type:** Python script

```pseudo
FOR EACH (timezone, valid) in:
  ("Europe/Vienna", true)
  ("America/New_York", true)
  ("EST", false)  # Not IANA format
  ("Invalid/Zone", false)
GIVEN config with timezone: $timezone
WHEN validating config
THEN is_valid equals $valid
```

### T15.6: Validate email format
**Code type:** Python script

```pseudo
GIVEN config with user.email: "invalid-email"
WHEN validating config
THEN error: "Invalid email format"
```

---

## Test Suite: Source Configuration

### T15.7: Source enable/disable
**Code type:** Python script

```pseudo
FOR EACH source in [gmail, calendar, slack, p2, linear, reminders]:
  GIVEN config with sources.$source.enabled: true
  WHEN checking if source enabled
  THEN returns true
  
  GIVEN config with sources.$source.enabled: false
  WHEN checking if source enabled
  THEN returns false
```

### T15.8: Gmail configuration
**Code type:** Python script

```pseudo
GIVEN sources.gmail section
THEN may contain:
  - enabled: boolean
  - exclude_categories: [list]
  - exclude_senders: [list]
```

### T15.9: Calendar configuration
**Code type:** Python script

```pseudo
GIVEN sources.calendar section
THEN may contain:
  - enabled: boolean
  - calendars: [list of calendar IDs]
  - buffer_minutes: integer
  - working_hours: {start: "HH:MM", end: "HH:MM"}
```

### T15.10: Slack configuration
**Code type:** Python script

```pseudo
GIVEN sources.slack section
THEN may contain:
  - enabled: boolean
  - include_channels: [list]
  - exclude_channels: [list]
  - include_at_channel: boolean
  - dm_priority: "high" | "normal"
```

### T15.11: P2 configuration
**Code type:** Python script

```pseudo
GIVEN sources.p2 section
THEN may contain:
  - enabled: boolean
  - include_sites: [list]
  - exclude_sites: [list]
  - track_my_posts: boolean
```

### T15.12: Linear configuration
**Code type:** Python script

```pseudo
GIVEN sources.linear section
THEN may contain:
  - enabled: boolean
  - personal_team: string (team key)
  - show_completed_days: integer
  - group_by: "team" | "project" | "priority"
  - include_backlog: boolean
```

### T15.13: Reminders configuration
**Code type:** Python script

```pseudo
GIVEN sources.reminders section
THEN may contain:
  - enabled: boolean
  - lists: [list of reminder list names]
  - upcoming_days: integer
  - show_completed: boolean
```

---

## Test Suite: Vault Configuration

### T15.14: Vault paths configuration
**Code type:** Python script

```pseudo
GIVEN vault section
THEN may contain:
  - path: <absolute path to vault>
  - daily_note_folder: "0_Inbox" (default)
  - archive_path: "6_Archive/Daily-Notes"
```

### T15.15: Validate vault path exists
**Code type:** Python script

```pseudo
GIVEN config with vault.path: "/nonexistent/path"
WHEN validating config
THEN warning: "Vault path does not exist"
```

---

## Test Suite: Behavior Configuration

### T15.16: Behavior section structure
**Code type:** Python script

```pseudo
GIVEN behavior section
THEN may contain:
  - auto_enrich: boolean
  - capture_threshold: integer (chars)
  - default_mode: "suggestion" | "interactive"
```

### T15.17: Capture threshold
**Code type:** Python script

```pseudo
GIVEN config with behavior.capture_threshold: 200
AND capture text of 150 chars
WHEN routing capture
THEN goes inline (under threshold)

AND capture text of 250 chars
WHEN routing capture
THEN creates file (over threshold)
```

---

## Test Suite: Config Loading

### T15.18: Load config on startup
**Code type:** Python script

```pseudo
GIVEN valid config file
WHEN system initializes
THEN config loaded into memory
AND accessible via get_config()
```

### T15.19: Merge with defaults
**Code type:** Python script

```pseudo
GIVEN config missing some fields
WHEN loading config
THEN missing fields filled from defaults
AND user values override defaults
```

### T15.20: Reload config without restart
**Code type:** Prompt/Response

```pseudo
GIVEN user modifies config.yaml
WHEN user says: "/reload config"
THEN config reloaded from file
AND new settings take effect
```

---

## Test Suite: Config Validation

### T15.21: Validate on load
**Code type:** Python script

```pseudo
GIVEN invalid config
WHEN loading
THEN validation errors reported
AND system may refuse to start or use defaults
```

### T15.22: Validate command
**Code type:** Bash script

```pseudo
GIVEN command: claude config validate
WHEN executed
THEN validates config file
AND reports any errors or warnings
```

### T15.23: Validate specific section
**Code type:** Bash script

```pseudo
GIVEN command: claude config validate sources.gmail
WHEN executed
THEN validates only gmail section
```

---

## Test Suite: Config Commands

### T15.24: Show current config
**Code type:** Bash script

```pseudo
GIVEN command: claude config show
WHEN executed
THEN displays current config (with sensitive values masked)
```

### T15.25: Show specific config value
**Code type:** Bash script

```pseudo
GIVEN command: claude config get sources.linear.personal_team
WHEN executed
THEN outputs: "Totoro"
```

### T15.26: Set config value
**Code type:** Bash script

```pseudo
GIVEN command: claude config set behavior.auto_enrich true
WHEN executed
THEN config.yaml updated
AND output: "Set behavior.auto_enrich = true"
```

### T15.27: Reset to default
**Code type:** Bash script

```pseudo
GIVEN command: claude config reset sources.gmail
WHEN executed
THEN gmail section reset to defaults
AND user values removed
```

---

## Test Suite: Environment Variables

### T15.28: Override via environment
**Code type:** Python script

```pseudo
GIVEN env var: CORTEX_USER_TIMEZONE=America/New_York
AND config has user.timezone: Europe/Vienna
WHEN loading config
THEN effective timezone is America/New_York (env overrides)
```

### T15.29: API keys from environment
**Code type:** Python script

```pseudo
GIVEN env var: LINEAR_API_KEY=lin_api_xxx
WHEN accessing Linear API
THEN uses key from environment
AND key not stored in config file
```

---

## Test Suite: Sensitive Data

### T15.30: No secrets in config file
**Code type:** Python script

```pseudo
GIVEN config.yaml
THEN file does NOT contain:
  - API keys
  - OAuth tokens
  - Passwords
AND secrets stored in secure location (keychain/env)
```

### T15.31: Mask secrets in output
**Code type:** Bash script

```pseudo
GIVEN command: claude config show
AND some secrets configured
THEN secrets displayed as: "***" or "[configured]"
```

---

## Test Suite: Error Handling

### T15.32: Handle missing config file
**Code type:** Python script

```pseudo
GIVEN 9_Meta/config.yaml doesn't exist
WHEN loading config
THEN creates default config
AND continues with defaults
```

### T15.33: Handle invalid YAML
**Code type:** Python script

```pseudo
GIVEN config.yaml contains invalid YAML
WHEN loading config
THEN error: "Invalid YAML syntax in config.yaml"
AND suggests fixing or resetting
```

### T15.34: Handle permission denied
**Code type:** Python script

```pseudo
GIVEN config.yaml is not readable
WHEN loading config
THEN error: "Cannot read config.yaml: permission denied"
```

---

## Mock Fixtures

### Default config.yaml
```yaml
# Digital Cortex Configuration
# Edit this file to customize behavior

user:
  name: ""
  email: ""
  timezone: "UTC"

sources:
  gmail:
    enabled: true
    exclude_categories: ["PROMOTIONS", "UPDATES"]
    exclude_senders: []
  
  calendar:
    enabled: true
    calendars: ["primary"]
    buffer_minutes: 15
    working_hours:
      start: "08:00"
      end: "18:00"
  
  slack:
    enabled: true
    include_channels: []
    exclude_channels: []
    include_at_channel: false
    dm_priority: "high"
  
  p2:
    enabled: true
    include_sites: []
    exclude_sites: []
    track_my_posts: true
  
  linear:
    enabled: true
    personal_team: "Totoro"
    show_completed_days: 1
    group_by: "team"
    include_backlog: false
  
  reminders:
    enabled: true
    lists: ["Reminders", "Shopping"]
    upcoming_days: 3
    show_completed: false

vault:
  path: ""
  daily_note_folder: "0_Inbox"
  archive_path: "6_Archive/Daily-Notes"

behavior:
  auto_enrich: true
  capture_threshold: 200
  default_mode: "suggestion"

sync:
  min_interval: 300
  cache_ttl: 300

memory:
  auto_context: true
  recent_limit: 10

people:
  auto_update_contact: true
  infer_company: true
```

### Test config with values
```yaml
user:
  name: "Paolo"
  email: "paolo@automattic.com"
  timezone: "Europe/Vienna"

sources:
  gmail:
    enabled: true
    exclude_categories: ["PROMOTIONS", "UPDATES", "SOCIAL"]
    exclude_senders: ["noreply@github.com"]
  
  linear:
    enabled: true
    personal_team: "Totoro"
    show_completed_days: 2

behavior:
  capture_threshold: 250
```
