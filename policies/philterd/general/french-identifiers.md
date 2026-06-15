---
title: "French Identifiers (NIR, SIREN, SIRET)"
slug: "french-identifiers"
category: "general"
tags: ["France", "NIR", "INSEE", "SIREN", "SIRET", "social security", "business ID"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-06-15"
philterCompatibility: "Requires Phileas 4.1.0+ (redaction policy schema 1.1.0 with the mod97 and luhn validators)"
useCase: "Redact French social-security numbers (NIR) and business identifiers (SIREN, SIRET), validated by their control key or Luhn check."
entities: ["FRENCH_NIR", "FRENCH_SIREN", "FRENCH_SIRET"]
exampleInput: "NIR 255081416802538, SIREN 732829320, SIRET 73282932000074."
exampleOutput: "NIR [REDACTED-FRENCH-NIR], SIREN [REDACTED-FRENCH-SIREN], SIRET [REDACTED-FRENCH-SIRET]."
---

## What this policy does

Detects and redacts three French identifiers using Phileas's generic `identifier` filter with a
validator, so each match is kept only if its check passes:

- **NIR** (the INSEE / social-security number, "numero de securite sociale"): 13-character body plus
  a two-digit control key, validated by the `mod97` validator (nir variant). Corsica department
  codes 2A and 2B are substituted (to 19 and 18) before the key is checked.
- **SIREN**: the 9-digit business registration number, validated by the `luhn` validator.
- **SIRET**: the 14-digit establishment number (SIREN plus a 5-digit NIC), validated by the `luhn`
  validator.

Each is replaced with a distinct token.

## Why the validators matter

A 9- or 14-digit pattern would over-match ordinary numbers. The validator keeps a match only if the
check passes, so `732829321` (a SIREN shape that fails the Luhn check) is left in place while
`732829320` is redacted. Detection remains probabilistic; validate against your own documents.

## Test vectors

- NIR, valid: `255081416802538` (and Corsica `220032A00801642`). Invalid (bad control key): `255081416802539`.
- SIREN, valid: `732829320`. Invalid (bad checksum): `732829321`.
- SIRET, valid: `73282932000074`. Invalid (bad checksum): `73282932000075`.

## Contextual cues

In free text, anchor on a nearby cue ("SIREN", "SIRET", "n de securite sociale") and capture only the
identifier with `groupNumber`:

```json
{
  "classification": "french-siren",
  "pattern": "SIREN[\\s:#-]*(\\d{9})",
  "caseSensitive": false,
  "groupNumber": 1,
  "validator": "luhn",
  "identifierFilterStrategies": [
    { "strategy": "REDACT", "redactionFormat": "[REDACTED-FRENCH-SIREN]" }
  ]
}
```

This trades recall for precision.

## Prerequisites

Use Phileas 4.1.0 or later, which provides redaction policy schema 1.1.0 and the `mod97` and `luhn`
validators. The example input and output were verified against Phileas 4.1.0.

## References

- [SIREN and SIRET (INSEE)](https://www.insee.fr/en/metadonnees/definition/c1391)
