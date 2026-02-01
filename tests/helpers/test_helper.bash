#!/usr/bin/env bash
# Test helper functions for Digital Cortex vault tests

# Path to the source scripts (to be implemented)
export SRC_DIR="${BATS_TEST_DIRNAME}/../../src"

# Test directories
export TEST_FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"
export TEST_VAULT_POPULATED="${TEST_FIXTURES_DIR}/test-vault-populated"
export TEST_TEMP_DIR=""

# Expected folder structure
export EXPECTED_FOLDERS=(
    ".claude"
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
)

# Expected numbered folders (excluding .claude)
export EXPECTED_NUMBERED_FOLDERS=(
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
)

# Expected meta files
export EXPECTED_META_FILES=(
    "config.yaml"
    "memory.md"
    "pending.json"
    "state.json"
)

# Create a clean temporary test vault directory
setup_test_vault() {
    local tmp_dir

    # Try GNU-style mktemp first; fall back to BSD/macOS -t form if needed
    if tmp_dir="$(mktemp -d 2>/dev/null)"; then
        :
    else
        tmp_dir="$(mktemp -d -t dc_vault_test.XXXXXX)"
    fi

    TEST_TEMP_DIR="$tmp_dir"
    export TEST_TEMP_DIR
}

# Clean up temporary test vault directory
teardown_test_vault() {
    if [[ -n "${TEST_TEMP_DIR}" && -d "${TEST_TEMP_DIR}" ]]; then
        rm -rf "${TEST_TEMP_DIR}"
    fi
}

# Source the vault management functions
# This will be implemented in src/vault.sh
load_vault_functions() {
    if [[ -f "${SRC_DIR}/vault.sh" ]]; then
        # shellcheck source=/dev/null
        source "${SRC_DIR}/vault.sh"
    else
        echo "Warning: ${SRC_DIR}/vault.sh not found. Functions not loaded." >&2
        return 1
    fi
}

# Helper to check if a directory exists
dir_exists() {
    [[ -d "$1" ]]
}

# Helper to check if a file exists
file_exists() {
    [[ -f "$1" ]]
}

# Helper to count directories at a given path (excluding . and ..)
count_dirs() {
    local path="$1"
    local count=0
    for item in "${path}"/*/ "${path}"/.*/ ; do
        [[ -d "$item" ]] || continue
        local name
        name=$(basename "$item")
        [[ "$name" == "." || "$name" == ".." ]] && continue
        ((count++))
    done
    echo "$count"
}

# Helper to check if folder name matches N_Name pattern
matches_folder_pattern() {
    local name="$1"
    [[ "$name" =~ ^[0-9]_[A-Za-z]+$ ]]
}

# Helper to check if a file/directory is writable
is_writable() {
    [[ -w "$1" ]]
}

# Helper to check if a file is readable
is_readable() {
    [[ -r "$1" ]]
}
