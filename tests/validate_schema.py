#!/usr/bin/env python3
"""Validate every policy JSON against the canonical Phileas schema.

The schema in schema/policy.schema.json is the canonical Phileas redaction
policy schema (the same one Phileas validates against). Validating here keeps
this library in lockstep with what the Phileas runtime actually accepts, so
field drift (e.g. `iban` vs `ibanCode`) is caught in CI rather than silently
dropping rules at runtime.
"""
import glob
import json
import pathlib
import sys

try:
    from jsonschema import Draft202012Validator
except ImportError:
    print("ERROR: the 'jsonschema' package is required. Install it with: pip install jsonschema",
          file=sys.stderr)
    sys.exit(2)

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCHEMA_PATH = ROOT / "schema" / "policy.schema.json"


def main() -> int:
    schema = json.loads(SCHEMA_PATH.read_text())
    validator = Draft202012Validator(schema)

    files = sorted(glob.glob(str(ROOT / "policies" / "**" / "*.json"), recursive=True))
    invalid = 0
    for f in files:
        policy = json.loads(pathlib.Path(f).read_text())
        errors = sorted(validator.iter_errors(policy), key=lambda e: list(e.absolute_path))
        if errors:
            invalid += 1
            rel = pathlib.Path(f).relative_to(ROOT)
            print(f"ERROR: {rel}: {len(errors)} schema violation(s)")
            for e in errors:
                path = ".".join(str(p) for p in e.absolute_path) or "(root)"
                print(f"    - [{path}] {e.message}")

    print(f"\nSchema-checked {len(files)} policy file(s); {invalid} invalid.")
    return 1 if invalid else 0


if __name__ == "__main__":
    sys.exit(main())
