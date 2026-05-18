---
title: "Bankruptcy Rule 9037 (FRBP 9037) Court Filing Redaction"
slug: "rule-9037-bankruptcy"
category: "legal"
tags: ["FRBP 9037", "bankruptcy", "court filings", "privacy", "PII"]
author: "Philterd"
version: "1.0.0"
updated: "2026-05-18"
philterCompatibility: ">=3.0.0"
useCase: "Redact bankruptcy court filings per FRBP 9037 — last 4 of SSN/TIN/account, year-only of birthdates, minors' names to initials."
entities: ["SSN", "TIN", "ACCOUNT", "BIRTHDATE", "MINOR_NAME"]
exampleInput: "Debtor Jane Doe (SSN 123-45-6789, born 1985-04-12) for account 1234567890. Minor child: Charles Doe."
exampleOutput: "Debtor Jane Doe (SSN xxxxxxx6789, born 1985) for account xxxxxx7890. Minor child: C.D."
---

## What this policy does

Implements the privacy-protection requirements of [Federal Rule of Bankruptcy Procedure 9037](https://www.law.cornell.edu/rules/frbp/rule_9037), which mirrors [Federal Rule of Civil Procedure 5.2](https://www.law.cornell.edu/rules/frcp/rule_5.2) for the bankruptcy courts. The rule requires that filings include only:

| Original PII | Permitted in filing |
|---|---|
| Social Security number | last 4 digits |
| Taxpayer identification number | last 4 digits |
| Date of birth | year only |
| Name of a minor | initials only |
| Financial account number | last 4 digits |

This policy enforces those rules automatically:

- **SSNs and TINs** — masked to last 4 (e.g., `xxxxxxx6789`).
- **Financial account numbers** — masked to last 4. The regex matches `ACCT 1234567890`, `Account: 1234567890`, etc.
- **Birthdates** — truncated to the 4-digit year. The `context == "birth"` condition only triggers on dates associated with a birth (DOB, "born", etc.) — other dates in the filing (hearings, transaction dates) pass through.
- **Minors' names** — replaced with initials. The `context == "minor"` condition relies on Philter detecting minor-related context (e.g., "minor child", "the minor", "juvenile"). For high-precision deployments, also configure a custom dictionary of known minor names.

## When to use this

- **Bankruptcy schedules** (Schedule A/B, Schedule E/F, Statement of Financial Affairs)
- **Proof of claim forms**
- **Adversary proceeding complaints and answers**
- **Any document filed with the bankruptcy court** that originated outside the court system

The same rule (FRBP 9037) applies regardless of which chapter (7, 11, 12, 13) the filing is for.

## When to customize

- **Account number format.** The default `\bACCT[\s:#]*\d{6,}\b` is illustrative. Replace with the specific patterns your case management system uses.
- **TIN format.** The default matches the `XX-XXXXXXX` EIN format. ITINs follow `9XX-XX-XXXX` and are caught by the SSN filter (since they share the SSN format).
- **Minor detection.** If your filings have a structured field for minor names (e.g., a "Minor Children" section), add a custom `section` filter to redact the entire section content.
- **Per-rule overrides.** FRCP 5.2(d) and FRBP 9037(d) allow filing unredacted documents under seal with court permission. This policy assumes you want full redaction — if you're preparing a filing for the protected order, use a less aggressive variant or pass through unmodified.

## Compliance notes

- **Federal Rule of Bankruptcy Procedure 9037** has been in effect since December 1, 2007. It applies to all documents filed with the U.S. Bankruptcy Courts.
- This policy implements only the **privacy-protection redactions** required by FRBP 9037(a). It does **not** handle the additional sealing or restricted-access provisions of FRBP 9037(d) (motion to redact under seal) or 9037(e) (additional protections by court order).
- Attorneys remain responsible for the accuracy of their filings. This policy is a tool to reduce manual redaction work, not a substitute for attorney review.

## References

- [FRBP 9037 — Privacy Protection For Filings Made with the Court](https://www.law.cornell.edu/rules/frbp/rule_9037)
- [FRCP 5.2 — Privacy Protection For Filings Made with the Court (civil)](https://www.law.cornell.edu/rules/frcp/rule_5.2)
- [Judiciary Privacy Policy and Public Access to Electronic Case Files](https://www.uscourts.gov/rules-policies/judiciary-policies/privacy-policy-electronic-case-files)
