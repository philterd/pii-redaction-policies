---
title: "German Identifiers (Steuer-ID, Personalausweis)"
slug: "german-identifiers"
category: "general"
tags: ["Germany", "Steuer-ID", "IdNr", "Personalausweis", "national ID", "tax ID"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-06-15"
philterCompatibility: "Requires Phileas 4.1.0+ (redaction policy schema 1.1.0 with the de-steuerid and de-personalausweis validators)"
useCase: "Redact German tax identification numbers (Steuer-ID / IdNr) and national ID card numbers (Personalausweis), validated by their check digits."
entities: ["GERMAN_STEUER_ID", "GERMAN_PERSONALAUSWEIS"]
exampleInput: "Steuer-ID 86095742719 and Ausweisnummer T220001293 on file."
exampleOutput: "Steuer-ID [REDACTED-GERMAN-STEUER-ID] and Ausweisnummer [REDACTED-GERMAN-PERSONALAUSWEIS] on file."
---

## What this policy does

Detects and redacts two German personal identifiers using Phileas's generic `identifier` filter
with a check-digit validator, so each match is kept only if its checksum is valid:

- **Steuer-ID** (Steuerliche Identifikationsnummer, "IdNr"): the 11-digit tax identification number,
  validated by the `de-steuerid` validator (the structural digit-repetition rule plus the ISO/IEC
  7064 MOD 11,10 check digit).
- **Personalausweis**: the 10-character national ID card number, validated by the
  `de-personalausweis` validator (the ICAO 9303 7-3-1 check digit).

Each is replaced with a distinct token (`[REDACTED-GERMAN-STEUER-ID]`,
`[REDACTED-GERMAN-PERSONALAUSWEIS]`).

## Why the validators matter

The patterns alone (eleven digits, or a letter followed by nine digits) would over-match ordinary
numbers. The validator keeps a match only if the check digit is correct, so a value such as
`86095742718` (a Steuer-ID shape with a wrong check digit) is left in place while the valid
`86095742719` is redacted. Detection is still probabilistic: a wrong-but-checksum-valid value can
pass, so validate against your own documents.

## Test vectors

- Steuer-ID, valid: `86095742719`. Invalid (bad check digit): `86095742718`.
- Personalausweis, valid: `T220001293`. Invalid (bad check digit): `T220001294`.

## Contextual cues

In free text where bare numbers are common, anchor on a nearby cue and capture only the identifier
with `groupNumber`. For example, require "Steuer-ID", "IdNr", or "Ausweisnummer" before the value:

```json
{
  "classification": "german-steuer-id",
  "pattern": "(?:Steuer-?ID|IdNr)[\\s:#-]*(\\d{11})",
  "caseSensitive": false,
  "groupNumber": 1,
  "validator": "de-steuerid",
  "identifierFilterStrategies": [
    { "strategy": "REDACT", "redactionFormat": "[REDACTED-GERMAN-STEUER-ID]" }
  ]
}
```

This trades recall (bare identifiers with no nearby cue are missed) for precision.

## Prerequisites

Use Phileas 4.1.0 or later, which provides redaction policy schema 1.1.0 and the `de-steuerid` and
`de-personalausweis` validators. On an older build the `validator` field is not applied. The example
input and output were verified against Phileas 4.1.0.

## References

- [Steuerliche Identifikationsnummer (BZSt)](https://www.bzst.de/EN/Private_individuals/Tax_identification_number/tax_identification_number_node.html)
