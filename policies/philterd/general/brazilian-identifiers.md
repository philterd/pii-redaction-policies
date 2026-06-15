---
title: "Brazilian Identifiers (CPF, CNPJ)"
slug: "brazilian-identifiers"
category: "general"
tags: ["Brazil", "CPF", "CNPJ", "tax ID", "national ID"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-06-15"
philterCompatibility: "Requires Phileas 4.1.0+ (redaction policy schema 1.1.0 with the mod11 validator)"
useCase: "Redact Brazilian CPF (individual) and CNPJ (company) tax identifiers, formatted or unformatted, validated by their mod-11 check digits."
entities: ["BRAZIL_CPF", "BRAZIL_CNPJ"]
exampleInput: "CPF 529.982.247-25 and CNPJ 11.222.333/0001-81 on file."
exampleOutput: "CPF [REDACTED-BR-CPF] and CNPJ [REDACTED-BR-CNPJ] on file."
---

## What this policy does

Detects and redacts the two Brazilian tax identifiers using Phileas's generic `identifier` filter
with the `mod11` validator, so each match is kept only if its mod-11 check digits are valid:

- **CPF** (Cadastro de Pessoas Fisicas): the 11-digit individual taxpayer number, validated by the
  `mod11` validator with the `cpf` variant.
- **CNPJ** (Cadastro Nacional da Pessoa Juridica): the 14-digit company number, validated by the
  `mod11` validator with the `cnpj` variant.

Both accept formatted (`000.000.000-00`, `00.000.000/0000-00`) and unformatted input, and each is
replaced with a distinct token.

## Why the validator matters

An 11- or 14-digit pattern would over-match. The validator keeps a match only if the two check
digits are correct, so `52998224724` (a CPF shape that fails the check) is left in place while
`52998224725` is redacted. Sequences of a single repeated digit are also rejected. Detection remains
probabilistic; validate against your own documents.

## Test vectors

- CPF, valid: `529.982.247-25` / `52998224725`. Invalid (bad check digit): `52998224724`.
- CNPJ, valid: `11.222.333/0001-81` / `11222333000181`. Invalid (bad check digit): `11222333000182`.

## Contextual cues

In free text, anchor on a nearby cue ("CPF", "CNPJ") and capture only the identifier with
`groupNumber`:

```json
{
  "classification": "br-cpf",
  "pattern": "CPF[\\s:#-]*(\\d{3}\\.?\\d{3}\\.?\\d{3}-?\\d{2})",
  "caseSensitive": false,
  "groupNumber": 1,
  "validator": { "name": "mod11", "params": { "variant": "cpf" } },
  "identifierFilterStrategies": [
    { "strategy": "REDACT", "redactionFormat": "[REDACTED-BR-CPF]" }
  ]
}
```

This trades recall for precision.

## Prerequisites

Use Phileas 4.1.0 or later, which provides redaction policy schema 1.1.0 and the `mod11` validator.
The example input and output were verified against Phileas 4.1.0.

## References

- [CPF and CNPJ (Receita Federal)](https://www.gov.br/receitafederal/pt-br)
