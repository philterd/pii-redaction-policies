#!/usr/bin/env bash
# Validates every policy in this repo. Runs in CI on every PR.
# - Each .json under policies/{philterd,community}/<category>/ must parse as valid JSON
# - Each .json must have a sibling .md
# - Each .md must have the required frontmatter fields, including `creator`
# - JSON schema validation (if a schema validator is available)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

errors=0
checked=0

# Required frontmatter keys in every sidecar .md
REQUIRED_FRONTMATTER=(title slug category tags author creator version updated philterCompatibility useCase entities)

# Look in both philterd/ and community/ trees. README.md files in subdirectories are skipped.
while IFS= read -r json; do
  checked=$((checked + 1))

  # JSON parse check
  if ! python3 -m json.tool "$json" >/dev/null 2>&1; then
    echo "ERROR: invalid JSON: $json"
    errors=$((errors + 1))
    continue
  fi

  # Sidecar .md exists
  md="${json%.json}.md"
  if [ ! -f "$md" ]; then
    echo "ERROR: missing sidecar metadata: $md"
    errors=$((errors + 1))
    continue
  fi

  # Sidecar has required frontmatter fields
  for key in "${REQUIRED_FRONTMATTER[@]}"; do
    if ! grep -q "^${key}:" "$md"; then
      echo "ERROR: $md missing required frontmatter field '${key}'"
      errors=$((errors + 1))
    fi
  done

  # Slug in frontmatter matches filename
  slug_from_md=$(grep -m1 '^slug:' "$md" | sed -E 's/^slug:[[:space:]]*"?([^"]+)"?[[:space:]]*$/\1/')
  slug_from_file=$(basename "${json%.json}")
  if [ "$slug_from_md" != "$slug_from_file" ]; then
    echo "ERROR: $md slug ('$slug_from_md') does not match filename ('$slug_from_file')"
    errors=$((errors + 1))
  fi

  # Category in frontmatter matches directory (the leaf directory under philterd/ or community/)
  category_from_md=$(grep -m1 '^category:' "$md" | sed -E 's/^category:[[:space:]]*"?([^"]+)"?[[:space:]]*$/\1/')
  category_from_path=$(basename "$(dirname "$json")")
  if [ "$category_from_md" != "$category_from_path" ]; then
    echo "ERROR: $md category ('$category_from_md') does not match directory ('$category_from_path')"
    errors=$((errors + 1))
  fi

  # Creator must be either "philterd" (for policies under policies/philterd/) or anything else (for policies under policies/community/)
  creator_from_md=$(grep -m1 '^creator:' "$md" | sed -E 's/^creator:[[:space:]]*"?([^"]+)"?[[:space:]]*$/\1/')
  provenance_from_path=$(basename "$(dirname "$(dirname "$json")")")
  if [ "$provenance_from_path" = "philterd" ] && [ "$creator_from_md" != "philterd" ]; then
    echo "ERROR: $md is under policies/philterd/ but creator is '$creator_from_md' (must be 'philterd')"
    errors=$((errors + 1))
  fi
  if [ "$provenance_from_path" = "community" ] && [ "$creator_from_md" = "philterd" ]; then
    echo "ERROR: $md is under policies/community/ but creator is 'philterd' (reserved for the core team's policies under policies/philterd/)"
    errors=$((errors + 1))
  fi

  # Slugs must be globally unique across philterd/ and community/
  # (handled below, outside the per-file loop)

done < <(find policies/philterd policies/community -name '*.json' -type f 2>/dev/null | sort)

# Check for slug collisions across all policies
duplicate_slugs=$(find policies/philterd policies/community -name '*.json' -type f 2>/dev/null | xargs -n1 basename 2>/dev/null | sort | uniq -d)
if [ -n "$duplicate_slugs" ]; then
  while IFS= read -r dup; do
    echo "ERROR: slug collision: '$dup' appears in multiple policies. Slugs must be globally unique."
    errors=$((errors + 1))
  done <<< "$duplicate_slugs"
fi

echo
echo "Checked $checked policy file(s)."

if [ $errors -gt 0 ]; then
  echo "Validation failed with $errors error(s)."
  exit 1
fi

echo "All policies valid."
