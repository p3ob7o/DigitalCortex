# T01: Vault Structure & Scaffolding — Tests

## Test Environment

```
test-vault/                    ← Clean directory for scaffolding tests
test-vault-populated/          ← Pre-populated vault for validation tests
```

---

## Test Suite: Folder Creation

### T01.1: Create all top-level folders
**Code type:** Bash script

```pseudo
GIVEN a clean directory at $TEST_VAULT_PATH
WHEN scaffold_vault($TEST_VAULT_PATH) is executed
THEN the following folders exist:
  - $TEST_VAULT_PATH/.claude/
  - $TEST_VAULT_PATH/0_Inbox/
  - $TEST_VAULT_PATH/1_Fleeting/
  - $TEST_VAULT_PATH/2_Drafts/
  - $TEST_VAULT_PATH/3_Projects/
  - $TEST_VAULT_PATH/4_Areas/
  - $TEST_VAULT_PATH/5_Resources/
  - $TEST_VAULT_PATH/6_Archive/
  - $TEST_VAULT_PATH/7_Assets/
  - $TEST_VAULT_PATH/8_People/
  - $TEST_VAULT_PATH/9_Meta/
AND folder count at top level equals 11 (10 numbered + .claude)
```

### T01.2: Create archive subfolder structure
**Code type:** Bash script

```pseudo
GIVEN scaffold_vault() has been executed
THEN the following path exists:
  - $TEST_VAULT_PATH/6_Archive/Daily-Notes/
AND Daily-Notes folder is empty (no year folders yet)
```

### T01.3: Create meta subfolder structure
**Code type:** Bash script

```pseudo
GIVEN scaffold_vault() has been executed
THEN the following paths exist:
  - $TEST_VAULT_PATH/9_Meta/prompts/
AND the following files exist:
  - $TEST_VAULT_PATH/9_Meta/config.yaml
  - $TEST_VAULT_PATH/9_Meta/memory.md
  - $TEST_VAULT_PATH/9_Meta/pending.json
  - $TEST_VAULT_PATH/9_Meta/state.json
```

### T01.4: Idempotent scaffolding
**Code type:** Bash script

```pseudo
GIVEN scaffold_vault() has been executed once
AND a file exists at $TEST_VAULT_PATH/0_Inbox/test-file.md
WHEN scaffold_vault($TEST_VAULT_PATH) is executed again
THEN no errors occur (exit code 0)
AND $TEST_VAULT_PATH/0_Inbox/test-file.md still exists with same content
AND folder structure is unchanged
```

---

## Test Suite: Folder Naming Convention

### T01.5: Folders follow N_Name convention
**Code type:** Bash script

```pseudo
GIVEN scaffold_vault() has been executed
WHEN listing top-level directories (excluding .claude)
THEN all folder names match pattern: ^[0-9]_[A-Za-z]+$
AND folders sort in order: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
```

### T01.6: Hidden folder for Claude config
**Code type:** Bash script

```pseudo
GIVEN scaffold_vault() has been executed
THEN .claude/ folder exists
AND .claude/ folder name starts with dot (is hidden)
AND .claude/ folder is at vault root level
```

---

## Test Suite: Validation

### T01.7: Validate complete vault structure
**Code type:** Bash script

```pseudo
GIVEN test-vault-populated/ exists with complete structure
WHEN validate_vault_structure($TEST_VAULT_POPULATED_PATH) is executed
THEN returns success (exit code 0)
AND outputs "Vault structure valid"
```

### T01.8: Detect missing folders
**Code type:** Bash script

```pseudo
GIVEN a directory with only 0_Inbox/ and 1_Fleeting/
WHEN validate_vault_structure($INCOMPLETE_PATH) is executed
THEN returns failure (exit code 1)
AND outputs list of missing folders
AND missing list includes: 2_Drafts, 3_Projects, 4_Areas, 5_Resources, 
    6_Archive, 7_Assets, 8_People, 9_Meta, .claude
```

### T01.9: Detect missing meta files
**Code type:** Bash script

```pseudo
GIVEN a vault with all folders but missing 9_Meta/config.yaml
WHEN validate_vault_structure($PATH) is executed
THEN returns failure (exit code 1)
AND outputs "Missing: 9_Meta/config.yaml"
```

### T01.10: Detect incorrect folder names
**Code type:** Bash script

```pseudo
GIVEN a vault with folder named "0-Inbox" (hyphen instead of underscore)
WHEN validate_vault_structure($PATH) is executed
THEN returns failure (exit code 1)
AND outputs "Invalid folder name: 0-Inbox (expected 0_Inbox)"
```

---

## Test Suite: Permissions

### T01.11: Folders are writable
**Code type:** Bash script

```pseudo
GIVEN scaffold_vault() has been executed
FOR EACH folder in [0_Inbox, 1_Fleeting, 2_Drafts, 3_Projects, 
                    4_Areas, 5_Resources, 6_Archive, 7_Assets, 
                    8_People, 9_Meta, .claude]:
  WHEN attempting to create a test file in $folder
  THEN file creation succeeds
  AND file can be deleted
```

### T01.12: Config files are readable and writable
**Code type:** Bash script

```pseudo
GIVEN scaffold_vault() has been executed
FOR EACH file in [config.yaml, memory.md, pending.json, state.json]:
  WHEN reading $file
  THEN read succeeds
  WHEN writing to $file
  THEN write succeeds
```

---

## Test Fixtures Required

### test-vault-populated/
```
test-vault-populated/
├── .claude/
├── 0_Inbox/
│   └── 2025-01-31 Friday.md
├── 1_Fleeting/
│   └── sample-fleeting.md
├── 2_Drafts/
├── 3_Projects/
│   └── test-project/
│       └── test-project.md
├── 4_Areas/
│   └── test-area.md
├── 5_Resources/
├── 6_Archive/
│   └── Daily-Notes/
│       └── 2025/
│           └── 01/
│               └── 2025-01-30 Thursday.md
├── 7_Assets/
├── 8_People/
│   └── jane-smith.md
└── 9_Meta/
    ├── prompts/
    │   ├── morning-brief.md
    │   ├── evening-review.md
    │   ├── weekly-review.md
    │   └── process-inbox.md
    ├── config.yaml
    ├── memory.md
    ├── pending.json
    └── state.json
```
