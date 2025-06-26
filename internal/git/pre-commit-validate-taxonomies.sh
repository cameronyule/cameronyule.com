#!/bin/bash

# This script validates tags and categories in Hugo content files
# against predefined lists in blog/data/taxonomies/.
# It should be used as a Git pre-commit hook.

# --- Configuration ---
HUGO_BLOG_DIR="blog"
ALLOWED_TAGS_FILE="${HUGO_BLOG_DIR}/data/taxonomies/allowed_tags.yaml"
ALLOWED_CATEGORIES_FILE="${HUGO_BLOG_DIR}/data/taxonomies/allowed_categories.yaml"

# --- Check for yq ---
if ! command -v yq &> /dev/null
then
    echo "Error: 'yq' (https://github.com/mikefarah/yq) is not installed."
    echo "Please install yq to enable taxonomy validation."
    exit 1
fi

# --- Load allowed taxonomies ---
# Read allowed tags into a bash array
# Using 'tr -d "\r"' to handle potential Windows line endings
readarray -t ALLOWED_TAGS < <(yq -r '.[]' "$ALLOWED_TAGS_FILE" | tr -d '\r')
if [ ${#ALLOWED_TAGS[@]} -eq 0 ]; then
    echo "Warning: No allowed tags found in ${ALLOWED_TAGS_FILE}. Validation for tags will be skipped."
fi

# Read allowed categories into a bash array
readarray -t ALLOWED_CATEGORIES < <(yq -r '.[]' "$ALLOWED_CATEGORIES_FILE" | tr -d '\r')
if [ ${#ALLOWED_CATEGORIES[@]} -eq 0 ]; then
    echo "Warning: No allowed categories found in ${ALLOWED_CATEGORIES_FILE}. Validation for categories will be skipped."
fi

# --- Validation Logic ---
VALIDATION_FAILED=0

# Get staged Markdown files within the blog content directory
# --diff-filter=ACM: Added, Copied, Modified files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "^${HUGO_BLOG_DIR}/content/.*\.md$")

if [ -z "$STAGED_FILES" ]; then
    echo "No new or modified Markdown files to validate."
    exit 0
fi

echo "Validating taxonomies in staged Markdown files..."

for FILE in $STAGED_FILES; do
    echo "  Checking ${FILE}..."
    
    # Extract YAML front matter (lines between the first two '---')
    # 'sed' is used here as 'yq' expects a file or stream, and we need to isolate the front matter.
    FRONT_MATTER=$(sed '/^---/,/^---/!d;//p' "$FILE" | sed '1d;$d')

    if [ -z "$FRONT_MATTER" ]; then
        echo "    Warning: No front matter found in ${FILE}. Skipping taxonomy validation for this file."
        continue
    fi

    # Extract tags from front matter, handling both scalar and array forms
    # Use '.tags[] // .tags // empty' to robustly get each tag, whether it's a scalar or an array.
    # Redirect stderr to /dev/null to suppress non-fatal jq errors from yq.
    FILE_TAGS=()
    readarray -t FILE_TAGS < <(yq -r '.tags[] // .tags // empty' <<< "$FRONT_MATTER" 2>/dev/null | tr -d '\r')

    # Extract categories from front matter, handling both scalar and array forms
    # Use '.categories[] // .categories // empty' to robustly get each category.
    # Redirect stderr to /dev/null to suppress non-fatal jq errors from yq.
    FILE_CATEGORIES=()
    readarray -t FILE_CATEGORIES < <(yq -r '.categories[] // .categories // empty' <<< "$FRONT_MATTER" 2>/dev/null | tr -d '\r')

    # Validate tags
    for TAG in "${FILE_TAGS[@]}"; do
        FOUND=0
        for ALLOWED_TAG in "${ALLOWED_TAGS[@]}"; do
            if [[ "$TAG" == "$ALLOWED_TAG" ]]; then
                FOUND=1
                break
            fi
        done
        if [ "$FOUND" -eq 0 ]; then
            echo "    Error: Invalid tag '${TAG}' found in ${FILE}. Please use an allowed tag from ${ALLOWED_TAGS_FILE}."
            VALIDATION_FAILED=1
        fi
    done

    # Validate categories
    for CATEGORY in "${FILE_CATEGORIES[@]}"; do
        FOUND=0
        for ALLOWED_CATEGORY in "${ALLOWED_CATEGORIES[@]}"; do
            if [[ "$CATEGORY" == "$ALLOWED_CATEGORY" ]]; then
                FOUND=1
                break
            fi
        done
        if [ "$FOUND" -eq 0 ]; then
            echo "    Error: Invalid category '${CATEGORY}' found in ${FILE}. Please use an allowed category from ${ALLOWED_CATEGORIES_FILE}."
            VALIDATION_FAILED=1
        fi
    done
done

if [ "$VALIDATION_FAILED" -eq 1 ]; then
    echo ""
    echo "Taxonomy validation failed. Please fix the errors before committing."
    exit 1
else
    echo "Taxonomy validation passed."
    exit 0
fi
