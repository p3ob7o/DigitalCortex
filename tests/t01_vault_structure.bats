#!/usr/bin/env bats
# T01: Vault Structure & Scaffolding Tests
#
# Tests for Digital Cortex vault scaffolding and validation.
# See requirements/T01-vault-structure.md for specifications.

# Load test helpers
load 'helpers/test_helper'

# =============================================================================
# Setup and Teardown
# =============================================================================

setup() {
    # Create a fresh temporary directory for each test
    setup_test_vault

    # Try to load vault functions (will warn if not yet implemented)
    load_vault_functions || true
}

teardown() {
    # Clean up temporary test directory
    teardown_test_vault
}

# =============================================================================
# Test Suite: Folder Creation
# =============================================================================

# T01.1: Create all top-level folders
@test "T01.1: scaffold_vault creates all top-level folders" {
    # Skip if scaffold_vault is not implemented yet
    if ! type scaffold_vault &>/dev/null; then
        skip "scaffold_vault function not yet implemented"
    fi

    # Execute scaffolding
    run scaffold_vault "$TEST_TEMP_DIR"
    [ "$status" -eq 0 ]

    # Verify all expected folders exist
    [ -d "$TEST_TEMP_DIR/.claude" ]
    [ -d "$TEST_TEMP_DIR/0_Inbox" ]
    [ -d "$TEST_TEMP_DIR/1_Fleeting" ]
    [ -d "$TEST_TEMP_DIR/2_Drafts" ]
    [ -d "$TEST_TEMP_DIR/3_Projects" ]
    [ -d "$TEST_TEMP_DIR/4_Areas" ]
    [ -d "$TEST_TEMP_DIR/5_Resources" ]
    [ -d "$TEST_TEMP_DIR/6_Archive" ]
    [ -d "$TEST_TEMP_DIR/7_Assets" ]
    [ -d "$TEST_TEMP_DIR/8_People" ]
    [ -d "$TEST_TEMP_DIR/9_Meta" ]

    # Verify folder count (11 = 10 numbered + .claude)
    local count
    count=$(find "$TEST_TEMP_DIR" -maxdepth 1 -type d | wc -l)
    # Subtract 1 for the directory itself
    [ "$((count - 1))" -eq 11 ]
}

# T01.2: Create archive subfolder structure
@test "T01.2: scaffold_vault creates archive subfolder structure" {
    if ! type scaffold_vault &>/dev/null; then
        skip "scaffold_vault function not yet implemented"
    fi

    run scaffold_vault "$TEST_TEMP_DIR"
    [ "$status" -eq 0 ]

    # Verify Daily-Notes subfolder exists
    [ -d "$TEST_TEMP_DIR/6_Archive/Daily-Notes" ]

    # Verify Daily-Notes is empty (no year folders yet)
    local content_count
    content_count=$(find "$TEST_TEMP_DIR/6_Archive/Daily-Notes" -mindepth 1 | wc -l)
    [ "$content_count" -eq 0 ]
}

# T01.3: Create meta subfolder structure
@test "T01.3: scaffold_vault creates meta subfolder structure and files" {
    if ! type scaffold_vault &>/dev/null; then
        skip "scaffold_vault function not yet implemented"
    fi

    run scaffold_vault "$TEST_TEMP_DIR"
    [ "$status" -eq 0 ]

    # Verify prompts subfolder exists
    [ -d "$TEST_TEMP_DIR/9_Meta/prompts" ]

    # Verify required meta files exist
    [ -f "$TEST_TEMP_DIR/9_Meta/config.yaml" ]
    [ -f "$TEST_TEMP_DIR/9_Meta/memory.md" ]
    [ -f "$TEST_TEMP_DIR/9_Meta/pending.json" ]
    [ -f "$TEST_TEMP_DIR/9_Meta/state.json" ]
}

# T01.4: Idempotent scaffolding
@test "T01.4: scaffold_vault is idempotent and preserves existing files" {
    if ! type scaffold_vault &>/dev/null; then
        skip "scaffold_vault function not yet implemented"
    fi

    # First scaffolding
    run scaffold_vault "$TEST_TEMP_DIR"
    [ "$status" -eq 0 ]

    # Create a test file in Inbox
    local test_file="$TEST_TEMP_DIR/0_Inbox/test-file.md"
    local test_content="This is test content that should be preserved"
    echo "$test_content" > "$test_file"

    # Second scaffolding
    run scaffold_vault "$TEST_TEMP_DIR"
    [ "$status" -eq 0 ]

    # Verify test file still exists with same content
    [ -f "$test_file" ]
    local actual_content
    actual_content=$(cat "$test_file")
    [ "$actual_content" = "$test_content" ]

    # Verify folder structure is intact
    [ -d "$TEST_TEMP_DIR/.claude" ]
    [ -d "$TEST_TEMP_DIR/0_Inbox" ]
    [ -d "$TEST_TEMP_DIR/9_Meta" ]
}

# =============================================================================
# Test Suite: Folder Naming Convention
# =============================================================================

# T01.5: Folders follow N_Name convention
@test "T01.5: numbered folders follow N_Name convention and sort correctly" {
    if ! type scaffold_vault &>/dev/null; then
        skip "scaffold_vault function not yet implemented"
    fi

    run scaffold_vault "$TEST_TEMP_DIR"
    [ "$status" -eq 0 ]

    # Get all top-level directories excluding .claude
    local folders=()
    while IFS= read -r -d '' dir; do
        local name
        name=$(basename "$dir")
        [[ "$name" == .* ]] && continue  # Skip hidden folders
        folders+=("$name")
    done < <(find "$TEST_TEMP_DIR" -maxdepth 1 -type d -print0 | sort -z)

    # Verify all numbered folders match pattern ^[0-9]_[A-Za-z]+$
    for folder in "${folders[@]}"; do
        [[ "$folder" =~ ^[0-9]_[A-Za-z]+$ ]]
    done

    # Verify sort order (0 through 9)
    local expected_order=(0 1 2 3 4 5 6 7 8 9)
    local idx=0
    for folder in "${folders[@]}"; do
        local num="${folder:0:1}"
        [ "$num" -eq "${expected_order[$idx]}" ]
        ((idx++))
    done
}

# T01.6: Hidden folder for Claude config
@test "T01.6: .claude folder exists and is hidden" {
    if ! type scaffold_vault &>/dev/null; then
        skip "scaffold_vault function not yet implemented"
    fi

    run scaffold_vault "$TEST_TEMP_DIR"
    [ "$status" -eq 0 ]

    # Verify .claude folder exists
    [ -d "$TEST_TEMP_DIR/.claude" ]

    # Verify folder name starts with dot (is hidden)
    local name
    name=$(basename "$TEST_TEMP_DIR/.claude")
    [[ "$name" == .* ]]

    # Verify .claude is at vault root level
    [ "$(dirname "$TEST_TEMP_DIR/.claude")" = "$TEST_TEMP_DIR" ]
}

# =============================================================================
# Test Suite: Validation
# =============================================================================

# T01.7: Validate complete vault structure
@test "T01.7: validate_vault_structure succeeds for complete vault" {
    if ! type validate_vault_structure &>/dev/null; then
        skip "validate_vault_structure function not yet implemented"
    fi

    # Use the pre-populated test fixture
    run validate_vault_structure "$TEST_VAULT_POPULATED"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Vault structure valid"* ]]
}

# T01.8: Detect missing folders
@test "T01.8: validate_vault_structure detects missing folders" {
    if ! type validate_vault_structure &>/dev/null; then
        skip "validate_vault_structure function not yet implemented"
    fi

    # Create incomplete vault with only 0_Inbox and 1_Fleeting
    mkdir -p "$TEST_TEMP_DIR/0_Inbox"
    mkdir -p "$TEST_TEMP_DIR/1_Fleeting"

    run validate_vault_structure "$TEST_TEMP_DIR"
    [ "$status" -eq 1 ]

    # Verify missing folders are reported
    [[ "$output" == *"2_Drafts"* ]]
    [[ "$output" == *"3_Projects"* ]]
    [[ "$output" == *"4_Areas"* ]]
    [[ "$output" == *"5_Resources"* ]]
    [[ "$output" == *"6_Archive"* ]]
    [[ "$output" == *"7_Assets"* ]]
    [[ "$output" == *"8_People"* ]]
    [[ "$output" == *"9_Meta"* ]]
    [[ "$output" == *".claude"* ]]
}

# T01.9: Detect missing meta files
@test "T01.9: validate_vault_structure detects missing meta files" {
    if ! type validate_vault_structure &>/dev/null; then
        skip "validate_vault_structure function not yet implemented"
    fi

    # Create vault structure without config.yaml
    mkdir -p "$TEST_TEMP_DIR"/{.claude,0_Inbox,1_Fleeting,2_Drafts,3_Projects,4_Areas,5_Resources,6_Archive/Daily-Notes,7_Assets,8_People,9_Meta/prompts}

    # Create other meta files but not config.yaml
    echo "{}" > "$TEST_TEMP_DIR/9_Meta/state.json"
    echo "{}" > "$TEST_TEMP_DIR/9_Meta/pending.json"
    echo "# Memory" > "$TEST_TEMP_DIR/9_Meta/memory.md"

    run validate_vault_structure "$TEST_TEMP_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Missing: 9_Meta/config.yaml"* ]]
}

# T01.10: Detect incorrect folder names
@test "T01.10: validate_vault_structure detects incorrect folder names" {
    if ! type validate_vault_structure &>/dev/null; then
        skip "validate_vault_structure function not yet implemented"
    fi

    # Create vault with incorrect folder name (hyphen instead of underscore)
    mkdir -p "$TEST_TEMP_DIR"/{.claude,0-Inbox,1_Fleeting,2_Drafts,3_Projects,4_Areas,5_Resources,6_Archive/Daily-Notes,7_Assets,8_People,9_Meta/prompts}

    # Create meta files
    echo "# Config" > "$TEST_TEMP_DIR/9_Meta/config.yaml"
    echo "{}" > "$TEST_TEMP_DIR/9_Meta/state.json"
    echo "{}" > "$TEST_TEMP_DIR/9_Meta/pending.json"
    echo "# Memory" > "$TEST_TEMP_DIR/9_Meta/memory.md"

    run validate_vault_structure "$TEST_TEMP_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid folder name: 0-Inbox"* ]]
    [[ "$output" == *"expected 0_Inbox"* ]]
}

# =============================================================================
# Test Suite: Permissions
# =============================================================================

# T01.11: Folders are writable
@test "T01.11: all folders are writable" {
    if ! type scaffold_vault &>/dev/null; then
        skip "scaffold_vault function not yet implemented"
    fi

    run scaffold_vault "$TEST_TEMP_DIR"
    [ "$status" -eq 0 ]

    # Test each folder for write permission
    local folders=(
        "0_Inbox"
        "1_Fleeting"
        "2_Drafts"
        "3_Projects"
        "4_Areas"
        "5_Resources"
        "6_Archive"
        "7_Assets"
        "8_People"
        "9_Meta"
        ".claude"
    )

    for folder in "${folders[@]}"; do
        local folder_path="$TEST_TEMP_DIR/$folder"

        # Verify folder is writable by creating and deleting a test file
        local test_file="$folder_path/.write-test-$$"
        touch "$test_file"
        [ -f "$test_file" ]
        rm "$test_file"
        [ ! -f "$test_file" ]
    done
}

# T01.12: Config files are readable and writable
@test "T01.12: config files are readable and writable" {
    if ! type scaffold_vault &>/dev/null; then
        skip "scaffold_vault function not yet implemented"
    fi

    run scaffold_vault "$TEST_TEMP_DIR"
    [ "$status" -eq 0 ]

    local meta_files=(
        "config.yaml"
        "memory.md"
        "pending.json"
        "state.json"
    )

    for file in "${meta_files[@]}"; do
        local file_path="$TEST_TEMP_DIR/9_Meta/$file"

        # Verify file exists
        [ -f "$file_path" ]

        # Verify file is readable
        [ -r "$file_path" ]
        cat "$file_path" > /dev/null

        # Verify file is writable
        [ -w "$file_path" ]
        echo "test write" >> "$file_path"
    done
}
