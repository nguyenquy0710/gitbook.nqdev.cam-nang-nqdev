#!/bin/bash
# Generate GitBook {% tabs %} model tables from JSON input
#
# Usage:
#   ./generate-model-tables.sh data.json
#   cat data.json | ./generate-model-tables.sh
#
# JSON format:
# {
#   "intro": "Optional intro paragraph (can be empty)",
#   "tabs": [
#     {
#       "title": "Tab Title",
#       "headers": ["Col1", "Col2", "Col3"],
#       "rows": [
#         ["val1", "val2", "val3"]
#       ]
#     }
#   ]
# }

set -euo pipefail

INPUT="${1:-/dev/stdin}"

if [ ! -f "$INPUT" ] && [ "$INPUT" != "/dev/stdin" ]; then
  echo "Error: File not found: $INPUT" >&2
  echo "Usage: $0 [file.json]" >&2
  exit 1
fi

DATA=$(cat "$INPUT")

# Extract intro (output as plain text if non-empty)
INTRO=$(echo "$DATA" | python3 -c "
import sys, json
data = json.load(sys.stdin)
intro = data.get('intro', '')
if intro:
    print(intro)
")

if [ -n "$INTRO" ]; then
  echo -e "\n$INTRO\n"
fi

# Generate tabs
echo '{% tabs %}'

TABS=$(echo "$DATA" | python3 -c "
import sys, json
data = json.load(sys.stdin)

for tab in data['tabs']:
    title = tab['title']
    headers = tab['headers']
    rows = tab['rows']

    print('TAB_START:' + title)
    # Header row
    print('| ' + ' | '.join(headers) + ' |')
    # Separator
    print('| ' + ' | '.join(['---'] * len(headers)) + ' |')
    # Data rows
    for row in rows:
        print('| ' + ' | '.join(row) + ' |')
    print('TAB_END')
")

while IFS= read -r line; do
  if [[ "$line" == TAB_START:* ]]; then
    title="${line#TAB_START:}"
    echo "{% tab title=\"$title\" %}"
  elif [[ "$line" == "TAB_END" ]]; then
    echo "{% endtab %}"
  else
    echo "$line"
  fi
done <<< "$TABS"

echo '{% endtabs %}'
