---
title: "State Court Filings Baseline Redaction"
slug: "state-court-filings-baseline"
category: "legal"
tags: ["state court", "court filings", "privacy", "PII", "baseline"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-05-22"
philterCompatibility: ">=3.0.0"
useCase: "A starting policy for state-court PII redaction — covers the most-common state requirements; tune for your specific jurisdiction."
entities: ["SSN", "TIN", "ACCOUNT", "BIRTHDATE", "MINOR_NAME", "DRIVERS_LICENSE", "WITNESS_ADDRESS", "WITNESS_PHONE"]
exampleInput: "Plaintiff Mary Roe (DL D1234567, SSN 999-88-7777, born 1978-11-03). Witness John Q. Smith resides at 4521 Maple Avenue and can be reached at (555) 234-9876. Minor child: Alex Roe. Account 9876543210."
exampleOutput: "Plaintiff Mary Roe (DL xxxxxxxx, SSN xxxxxxx7777, born 1978). Witness John Q. Smith resides at {{{REDACTED-address}}} and can be reached at {{{REDACTED-phone-number}}}. Minor child: A.R. Account xxxxxx3210."
---

## What this policy does

A **baseline** redaction policy covering the PII categories most commonly required to be redacted across U.S. state-court rules. Unlike the federal rules (FRCP 5.2, FRBP 9037), state rules vary substantially — there is no single national standard. This policy implements the *most-common* state-court requirements as the starting point; the sidecar notes call out the jurisdictional variation you'll need to research and tune for.

| Original PII | Redaction in filing |
|---|---|
| Social Security number | last 4 digits |
| Taxpayer identification number | last 4 digits |
| Date of birth | year only |
| Name of a minor | initials only |
| Financial account number | last 4 digits |
| Driver's license number | fully masked |
| Witness/victim home address | fully redacted (context-gated) |
| Witness/victim phone number | fully redacted (context-gated) |

## When to use this

- **Civil complaints, answers, and motions** filed in state district / superior / circuit courts.
- **Family-law filings** (divorce, custody, support) where minor names and adult addresses commonly require redaction.
- **State-court probate filings** with financial-account details.
- **Civil-protection-order filings** where petitioner/witness contact information is typically protected.
- **Any state-court filing** where you want a starting baseline before tuning for the specific jurisdiction's rule.

Do **not** use this policy as a final filing-ready output without verifying against your jurisdiction's specific court rules. State rules diverge meaningfully; some require less redaction than this baseline (which is over-protective), and some require more (which means tuning is required).

## Why this is a "baseline" and not a final policy

State-court PII rules vary across at least these axes:

- **What gets redacted at all.** Some states track FRCP 5.2 closely; others add categories (driver's license, vehicle plates, biometric identifiers); a few are more permissive (only SSN and minor names).
- **What format is preserved.** Some states require last-4 of an account number; others require full redaction; a few allow first-4-and-last-4.
- **What contexts trigger redaction.** Witness and victim contact information is typically protected in domestic-violence and child-protection matters but not in routine civil cases. The `context` conditions in this policy give you the hook to tune that behavior; the default protects witness/victim contact info conservatively.
- **What records are sealed entirely.** Most states have separate rules for fully-sealed filings (juvenile delinquency, mental-health commitment, certain protective orders) that aren't a redaction problem so much as a routing problem. This policy doesn't address the routing.

## When to customize

- **Drop categories your state doesn't require.** If you're filing in a jurisdiction with a permissive rule, removing the `streetAddress`, `phoneNumber`, or `driversLicense` blocks reduces over-redaction.
- **Add categories your state requires.** Common additions: vehicle license plates, financial account routing numbers, biometric identifiers, alien registration numbers.
- **Tighten or loosen the `context` gates.** The witness/victim context gates may be too broad in routine civil filings (where witness contact info is regularly disclosed) or too narrow in DV/family-law filings (where adult parties' contact info also needs protection).
- **Account number format.** The default `\bACCT[\s:#]*\d{6,}\b` is illustrative. Replace with the specific patterns your case-management system uses.
- **Minor name detection.** If your filings have a structured field for minor parties or children, add a custom `section` filter to redact the entire section content rather than relying on context detection.

## Compliance notes

- This policy is a **starting point**, not a certified-compliant configuration for any specific jurisdiction. You must consult your court's rules of civil / criminal / family / probate procedure before relying on this policy for filed documents.
- Many state courts publish guidance on PII redaction in their **local rules** or in administrative orders separate from the rules of procedure. Check both.
- Several states have separate **electronic-filing standards** that govern PII handling for documents submitted via the court's e-filing system; those standards sometimes differ from the paper-filing rules.
- The redaction here is **technical**, not legal. Attorneys remain responsible for the accuracy and completeness of their filings, including verifying that the redaction satisfies the applicable rule.

## References

- [National Center for State Courts — Privacy and Access to Court Records](https://www.ncsc.org/topics/access-and-fairness/privacy-public-access-to-court-records/state-links)
- [FRCP 5.2 — Privacy Protection For Filings Made with the Court (federal civil baseline that many states track)](https://www.law.cornell.edu/rules/frcp/rule_5.2)
- For state-specific rules, consult the court's rules of civil procedure and any local rules of the specific court of filing.
