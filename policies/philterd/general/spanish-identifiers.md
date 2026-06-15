---
title: "Spanish Identifiers (DNI, NIE, CIF)"
slug: "spanish-identifiers"
category: "general"
tags: ["Spain", "DNI", "NIE", "CIF", "national ID", "tax ID"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-06-15"
philterCompatibility: "Requires Phileas 4.1.0+ (redaction policy schema 1.1.0 with the mod23-letter and es-cif validators)"
useCase: "Redact Spanish personal and organization identifiers (DNI, NIE, CIF), validated by their control letter or character."
entities: ["SPANISH_DNI", "SPANISH_NIE", "SPANISH_CIF"]
exampleInput: "DNI 12345678Z, NIE X1234567L, CIF A58818501."
exampleOutput: "DNI [REDACTED-SPANISH-DNI], NIE [REDACTED-SPANISH-NIE], CIF [REDACTED-SPANISH-CIF]."
---

## What this policy does

Detects and redacts three Spanish identifiers using Phileas's generic `identifier` filter with a
control-character validator, so each match is kept only if its control is correct:

- **DNI** (Documento Nacional de Identidad): 8 digits and a control letter, validated by the
  `mod23-letter` validator.
- **NIE** (Numero de Identidad de Extranjero): a leading X, Y, or Z (mapped to 0, 1, 2), 7 digits,
  and a control letter, validated by the `mod23-letter` validator.
- **CIF** (the organization tax identifier): a leading organization-type letter, 7 digits, and a
  control digit or letter, validated by the `es-cif` validator.

Each is replaced with a distinct token.

## Why the validators matter

The shapes alone (eight digits plus a letter, and so on) would over-match. The validator keeps a
match only if the control character is correct, so `12345678A` (a DNI shape with the wrong control
letter) is left in place while `12345678Z` is redacted. Detection remains probabilistic; validate
against your own documents.

## Test vectors

- DNI, valid: `12345678Z`. Invalid (wrong control letter): `12345678A`.
- NIE, valid: `X1234567L`. Invalid (wrong control letter): `X1234567A`.
- CIF, valid: `A58818501`. Invalid (wrong control character): `A58818502`.

## Contextual cues

In free text, anchor on a nearby cue ("DNI", "NIE", "CIF") and capture only the identifier with
`groupNumber`:

```json
{
  "classification": "spanish-dni",
  "pattern": "DNI[\\s:#-]*(\\d{8}[A-Za-z])",
  "caseSensitive": false,
  "groupNumber": 1,
  "validator": "mod23-letter",
  "identifierFilterStrategies": [
    { "strategy": "REDACT", "redactionFormat": "[REDACTED-SPANISH-DNI]" }
  ]
}
```

This trades recall for precision.

## Prerequisites

Use Phileas 4.1.0 or later, which provides redaction policy schema 1.1.0 and the `mod23-letter` and
`es-cif` validators. The example input and output were verified against Phileas 4.1.0.

## References

- [Spanish DNI / NIE (Wikipedia)](https://en.wikipedia.org/wiki/Documento_Nacional_de_Identidad_(Spain))
