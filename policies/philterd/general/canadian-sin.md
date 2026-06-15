---
title: "Canadian Social Insurance Number (SIN) Redaction"
slug: "canadian-sin"
category: "general"
tags: ["Canada", "SIN", "Social Insurance Number", "National ID", "Luhn"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-06-15"
philterCompatibility: "Requires Phileas 4.1.0+ (redaction policy schema 1.1.0 and the luhn validator)"
useCase: "Redact Canadian Social Insurance Numbers (SIN), accepting formatted and unformatted nine-digit values and rejecting Luhn-invalid look-alikes."
entities: ["CANADA_SIN"]
exampleInput: "Employee SIN on file: 046 454 286. Reference number 123 456 789 is not a SIN."
exampleOutput: "Employee SIN on file: [REDACTED-CANADA-SIN]. Reference number 123 456 789 is not a SIN."
---

## What this policy does

Detects and redacts the Canadian **Social Insurance Number (SIN)**, the nine-digit
number issued to individuals to work in Canada and access government programs. The SIN
appears in onboarding paperwork, payroll, tax forms, and benefits records, so it is a
common identifier to strip before sharing or retaining those documents.

The policy uses Phileas's generic `identifier` filter with two parts:

- **A pattern** that matches a nine-digit number written either unformatted
  (`046454286`), space-separated (`046 454 286`), or hyphenated (`046-454-286`).
- **The `luhn` validator**, which keeps a match only if its digits pass the standard
  mod-10 Luhn checksum. The SIN is a Luhn-valid number, so this rejects the many
  nine-digit values that merely look like a SIN but are not (an order number, a padded
  account number, an arbitrary nine-digit reference).

Matches are replaced with `[REDACTED-CANADA-SIN]`.

## Why the validator matters

A bare nine-digit pattern over-matches: any run of nine digits would be redacted,
including reference numbers, partial account numbers, and other non-SIN values. The
Luhn check is what makes this entry precise without a dedicated, code-heavy filter. For
example, `046 454 286` is Luhn-valid and is redacted, while `123 456 789` matches the
same shape but fails the checksum and is left in place.

The validator narrows false positives; it does not eliminate them. A random nine-digit
number passes Luhn roughly one time in ten, so a Luhn-valid value is not guaranteed to be
a SIN. For higher precision in free text, anchor on context (see "When to customize"),
and always validate the policy against your own representative documents.

## When to use this

- **Employee and HR records:** onboarding forms, payroll files, T4 and tax slips, benefits
  enrollment.
- **Records shared with a third party:** payroll processors, benefits administrators, or
  auditors who do not need the raw SIN.
- **De-identifying datasets** drawn from Canadian customer or employee data before analytics
  or model training.

## When to customize

- **Anchor on context for higher precision.** In free-form text where bare nine-digit
  numbers are common, require a nearby cue and redact only the captured digits with
  `groupNumber`:

  ```json
  {
    "classification": "canada-sin",
    "pattern": "\\b(?:SIN|Social Insurance Number|num[ée]ro d'assurance sociale)[\\s:#-]*((?:\\d{3}[ -]?){2}\\d{3})\\b",
    "caseSensitive": false,
    "groupNumber": 1,
    "validator": "luhn",
    "identifierFilterStrategies": [
      { "strategy": "REDACT", "redactionFormat": "[REDACTED-CANADA-SIN]" }
    ]
  }
  ```

  This matches only a SIN introduced by "SIN", "Social Insurance Number", or the French
  "numéro d'assurance sociale", and redacts just the number, leaving the label in place.
  It trades recall (bare SINs with no nearby cue are missed) for precision.

- **Mask instead of redact.** To keep the last digits visible for reconciliation, swap the
  strategy to `MASK` with a `maskLength` rather than `REDACT`.

- **Tighten the separators.** The default accepts space or hyphen between groups, including
  mixed separators. If your documents use exactly one convention, narrow the pattern to it.

## Prerequisites and compatibility

This policy depends on capabilities added in **redaction policy schema 1.1.0**:

- The `validator` field on the `identifier` filter (added in schema 1.1.0).
- The `luhn` validator, implemented in **Phileas 4.1.0** (Java).

Use Phileas 4.1.0 or later, or a Philter release that bundles it. On an older build that
predates schema 1.1.0 or the `luhn` validator, the `validator` field is not applied and the
identifier would redact every nine-digit match (including checksum-invalid ones), so do not
rely on this policy there.

The `luhn` validator currently ships in Phileas (Java). The `phileas-python` and
`phileas-dotnet` bindings do not implement it yet, so this policy validates as intended only
on the Java runtime until that parity lands. The example input and output below were verified
against Phileas 4.1.0.

## References

- [Social Insurance Number (Government of Canada)](https://www.canada.ca/en/employment-social-development/services/sin.html)
- [Luhn algorithm](https://en.wikipedia.org/wiki/Luhn_algorithm)
