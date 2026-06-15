---
title: "SWIFT / BIC Codes"
slug: "swift-bic-codes"
category: "finance"
tags: ["SWIFT", "BIC", "ISO 9362", "banking", "wire transfer"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-06-15"
philterCompatibility: "Requires Phileas 4.1.0+ (redaction policy schema 1.1.0 with the bic-structural validator)"
useCase: "Redact SWIFT/BIC bank and business identifier codes (ISO 9362), validated structurally including a valid ISO 3166 country segment."
entities: ["SWIFT_BIC"]
exampleInput: "Send the wire to DEUTDEFF (or DEUTDEFF500 for the branch)."
exampleOutput: "Send the wire to [REDACTED-SWIFT-BIC] (or [REDACTED-SWIFT-BIC] for the branch)."
---

## What this policy does

Detects and redacts SWIFT/BIC codes using Phileas's generic `identifier` filter with the
`bic-structural` validator. SWIFT/BIC has no checksum, so the validator checks the ISO 9362 structure
(4 letters institution, 2 letters country, 2 alphanumeric location, optional 3 alphanumeric branch,
for a length of 8 or 11) and requires the country segment to be a valid ISO 3166-1 alpha-2 code.

Matches are replaced with `[REDACTED-SWIFT-BIC]`.

## Why the validator matters

The BIC shape alone would match strings that merely look like a BIC. The validator keeps a match only
if it is structurally valid with a real country code, so `DEUTZZFF` (a BIC shape with the unassigned
country `ZZ`) is left in place while `DEUTDEFF` is redacted. A structurally valid code is not
guaranteed to be an assigned BIC, so detection remains probabilistic; validate against your own
documents.

## Test vectors

- Valid 8-character: `DEUTDEFF`, `BOFAUS3N`. Valid 11-character: `DEUTDEFF500`.
- Invalid 8-character (unassigned country `ZZ`): `DEUTZZFF`. Invalid 11-character: `DEUTZZFF500`.

## Contextual cues

In free text, anchor on a nearby cue ("SWIFT", "BIC") and capture only the code with `groupNumber`:

```json
{
  "classification": "swift-bic",
  "pattern": "(?:SWIFT|BIC)[\\s:#-]*([A-Z]{4}[A-Z]{2}[A-Z0-9]{2}(?:[A-Z0-9]{3})?)",
  "caseSensitive": true,
  "groupNumber": 1,
  "validator": "bic-structural",
  "identifierFilterStrategies": [
    { "strategy": "REDACT", "redactionFormat": "[REDACTED-SWIFT-BIC]" }
  ]
}
```

This trades recall for precision.

## Prerequisites

Use Phileas 4.1.0 or later, which provides redaction policy schema 1.1.0 and the `bic-structural`
validator. The example input and output were verified against Phileas 4.1.0.

## References

- [ISO 9362 Business Identifier Code (SWIFT)](https://www.swift.com/standards/data-standards/bic-business-identifier-code)
