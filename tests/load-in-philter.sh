#!/usr/bin/env bash
#
# Loads every policy into a running Philter and redacts a sample with it. Fails if Philter refuses a
# policy or cannot redact with it, such as a policy whose PhEye filter needs a service Philter does
# not have. It does not compare output; checking each policy's example output is a separate test.
#
#   PHILTER_API_KEY=sk_... bash tests/load-in-philter.sh
#
# PHILTER_URL defaults to https://localhost:8080.

set -euo pipefail

cd "$(dirname "$0")/.."

URL="${PHILTER_URL:-https://localhost:8080}"
: "${PHILTER_API_KEY:?Set PHILTER_API_KEY to a Philter API key.}"

TEXT="Patient John Smith (SSN 123-45-6789, john@example.com) was discharged on 2025-03-14."
RESPONSE="$(mktemp)"
trap 'rm -f "$RESPONSE"' EXIT

failures=0
count=0

while IFS= read -r policy; do
    slug="$(basename "$policy" .json)"
    count=$((count + 1))

    # -k: Philter serves HTTPS with a self-signed certificate by default.
    status=$(curl -sk -o "$RESPONSE" -w '%{http_code}' -X POST "$URL/api/policies?name=$slug" \
        -H "Authorization: Bearer $PHILTER_API_KEY" \
        -H "Content-Type: application/json" \
        --data @"$policy")
    if [ "$status" != "201" ]; then
        echo "FAIL $slug: upload returned $status: $(head -c 400 "$RESPONSE")"
        failures=$((failures + 1))
        continue
    fi

    status=$(curl -sk -o "$RESPONSE" -w '%{http_code}' "$URL/api/filter?p=$slug" \
        -H "Authorization: Bearer $PHILTER_API_KEY" \
        -H "Content-Type: text/plain" \
        --data-binary "$TEXT")
    if [ "$status" != "200" ]; then
        echo "FAIL $slug: redaction returned $status: $(head -c 400 "$RESPONSE")"
        failures=$((failures + 1))
        continue
    fi

    echo "ok   $slug"
done < <(find policies -name '*.json' | sort)

echo "Loaded $count policies, $failures failed."
[ "$failures" -eq 0 ]
