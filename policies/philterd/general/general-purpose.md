---
title: "General-Purpose Starter Policy"
slug: "general-purpose"
category: "general"
tags: ["starter", "general", "default"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-05-18"
philterCompatibility: ">=3.0.0"
useCase: "A balanced starting policy covering common PII types — names, contact info, government IDs, payment data — with no vertical-specific tuning."
entities: ["NAME", "PHONE", "EMAIL", "SSN", "CREDIT_CARD", "IP", "URL", "IBAN", "PASSPORT", "DRIVERS_LICENSE"]
exampleInput: "Contact Jane Doe at jane@example.com or 555-867-5309. Card 4111111111111111 on file. License #D1234567."
exampleOutput: "Contact {{{REDACTED-name}}} at {{{REDACTED-email-address}}} or {{{REDACTED-phone-number}}}. Card {{{REDACTED-credit-card}}} on file. License #{{{REDACTED-drivers-license}}}."
---

## What this policy does

A reasonable default for "I just want to redact common PII without thinking about it too hard." Catches:

- **Personal identity**: names (confidence-gated to reduce false positives), passport numbers, driver's license numbers
- **Contact info**: phone numbers, email addresses, URLs, IP addresses
- **Government identifiers**: SSNs
- **Financial**: credit cards (Luhn-validated), IBANs

Does **not** cover:

- Healthcare-specific identifiers (MRN, hospital names) — use a [healthcare policy](../healthcare/) instead
- PCI-specific masking (this policy fully redacts cards; for PCI scope reduction with last-4 visible, use [pci-dss-scope-reduction.json](../finance/pci-dss-scope-reduction.md))
- Court-filing rules (use [legal policies](../legal/))
- Custom identifiers (MRNs, account numbers, internal IDs) — add `identifiers` patterns for your domain

## When to use this

- **Quick starts** when you're evaluating Philter against your data
- **Catch-all log scrubbing** in non-regulated environments
- **Default-deny** posture: redact aggressively, then loosen specific entity types as your use case clarifies

## When NOT to use this

- **Regulated workloads.** HIPAA, PCI, GDPR, FERPA, and similar regimes have specific requirements — use a policy designed for that framework.
- **Datasets where over-redaction breaks downstream value.** This policy is biased toward over-redaction. For research, ML, or analytics use cases, see the date-shifted clinical-notes policy or build a domain-specific one.

## When to customize

- **Name confidence.** Default `> 70` is moderately conservative. Lower to `> 50` for higher recall (catches more rare/foreign names at the cost of false positives on capitalized common words). Raise to `> 85` for higher precision.
- **URL and IP redaction.** Some applications need to retain these for analytics. Remove the `url` or `ipAddress` entries if so.
- **Add custom identifiers** for any deployment-specific patterns: internal customer IDs, ticket numbers, employee badges, etc.

## Tuning workflow

1. Run this policy against a representative sample of your data.
2. Inspect the redactions. Note any over-redaction (legitimate text caught) or under-redaction (PII missed).
3. Tighten thresholds, add `ignored` terms, or add custom `identifiers` patterns based on what you find.
4. Re-evaluate. Repeat until precision and recall meet your bar.

[Philter Scope](https://philterd.ai/philter-scope/) automates step 3 — score policy changes against a gold-standard test set so you can measure regressions instead of guessing at them.
