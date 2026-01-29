#!/bin/bash
# Output CLAUDE.md ADRs section content
# Usage: sync-claude-md.sh /path/to/adrs
#
# This outputs the formatted section content. Claude handles editing CLAUDE.md.

ADR_DIR="$1"

if [ -z "$ADR_DIR" ]; then
    echo "Usage: sync-claude-md.sh /path/to/adrs" >&2
    exit 1
fi

if [ ! -d "$ADR_DIR" ]; then
    echo "Error: Directory not found: $ADR_DIR" >&2
    exit 1
fi

# Extract frontmatter from a file (first line must be ---, content until second ---)
extract_frontmatter() {
    awk '/^---$/{n++; if(n==2) exit; next} n==1{print}' "$1"
}

# Output section header
echo "## ADRs"
echo ""

FOUND_ANY=false

# Process each ADR file
for file in $(ls -1 "$ADR_DIR"/*.md 2>/dev/null | grep -E '/[0-9]{3}-' | sort); do
    [ ! -f "$file" ] && continue
    [[ "$file" == *"template"* ]] && continue

    FRONTMATTER=$(extract_frontmatter "$file")

    # Check if context-critical
    CRITICAL=$(yq -r '.["context-critical"] // false' <<< "$FRONTMATTER" 2>/dev/null)

    if [ "$CRITICAL" != "true" ]; then
        continue
    fi

    ID=$(yq -r '.id // ""' <<< "$FRONTMATTER" 2>/dev/null)
    STATUS=$(yq -r '.status // ""' <<< "$FRONTMATTER" 2>/dev/null)
    SUMMARY=$(yq -r '.summary // ""' <<< "$FRONTMATTER" 2>/dev/null)

    [ -z "$ID" ] && continue
    [ -z "$SUMMARY" ] && continue

    # Only include active ADRs
    if [ "$STATUS" != "proposed" ] && [ "$STATUS" != "accepted" ]; then
        continue
    fi

    echo "- $SUMMARY - $ID"
    FOUND_ANY=true
done

if [ "$FOUND_ANY" = false ]; then
    echo "_No context-critical ADRs. Run \`/adr new\` to create one._"
fi
