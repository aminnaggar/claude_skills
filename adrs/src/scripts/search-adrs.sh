#!/bin/bash
# Search ADRs by content or tags
# Usage: search-adrs.sh /path/to/adrs "query"

ADR_DIR="$1"
QUERY="$2"

if [ -z "$ADR_DIR" ] || [ -z "$QUERY" ]; then
    echo "Usage: search-adrs.sh /path/to/adrs \"query\"" >&2
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

# Search using ripgrep, then show matching ADRs
MATCHES=$(rg -l -i "$QUERY" "$ADR_DIR"/*.md 2>/dev/null | grep -E '/[0-9]{3}-' | sort)

if [ -z "$MATCHES" ]; then
    echo "No ADRs found matching: $QUERY"
    exit 0
fi

printf "%-10s %-12s %-50s\n" "ID" "STATUS" "TITLE"
printf "%s\n" "================================================================================"

for file in $MATCHES; do
    [[ "$file" == *"template"* ]] && continue

    FRONTMATTER=$(extract_frontmatter "$file")

    ID=$(yq -r '.id // ""' <<< "$FRONTMATTER" 2>/dev/null)
    STATUS=$(yq -r '.status // ""' <<< "$FRONTMATTER" 2>/dev/null)
    TITLE=$(yq -r '.title // ""' <<< "$FRONTMATTER" 2>/dev/null)

    [ -z "$ID" ] && continue

    if [ ${#TITLE} -gt 48 ]; then
        TITLE="${TITLE:0:45}..."
    fi

    printf "%-10s %-12s %-50s\n" "$ID" "$STATUS" "$TITLE"
done
