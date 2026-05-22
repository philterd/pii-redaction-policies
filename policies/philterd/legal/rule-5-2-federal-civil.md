---
title: "FRCP 5.2 Federal Civil Filing Redaction"
slug: "rule-5-2-federal-civil"
category: "legal"
tags: ["FRCP 5.2", "federal civil", "court filings", "privacy", "PII"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-05-22"
philterCompatibility: ">=3.0.0"
useCase: "Redact federal civil filings per FRCP 5.2 — last 4 of SSN/TIN/account, year-only birthdates, minor names to initials."
entities: ["SSN", "TIN", "ACCOUNT", "BIRTHDATE", "MINOR_NAME"]
exampleInput: "Plaintiff Jane Doe (SSN 123-45-6789, born 1985-04-12) for account 1234567890. Minor child: Charles Doe."
exampleOutput: "Plaintiff Jane Doe (SSN xxxxxxx6789, born 1985) for account xxxxxx7890. Minor child: C.D."
---

## What this policy does

Implements the privacy-protection requirements of [Federal Rule of Civil Procedure 5.2](https://www.law.cornell.edu/rules/frcp/rule_5.2), which governs documents filed in U.S. district courts in civil matters. The rule requires that filings include only:

| Original PII | Permitted in filing |
|---|---|
| Social Security number | last 4 digits |
| Taxpayer identification number | last 4 digits |
| Date of birth | year only |
| Name of a minor | initials only |
| Financial account number | last 4 digits |

This policy is the federal-civil sibling of [`rule-9037-bankruptcy`](../rule-9037-bankruptcy/) (which covers FRBP 9037 for bankruptcy filings). The redaction rules are identical between the two; the difference is which courts they apply in. Use this policy for federal district court civil matters; use the 9037 policy for bankruptcy.

This policy enforces those rules automatically:

- **SSNs and TINs** — masked to last 4 (e.g., `xxxxxxx6789`).
- **Financial account numbers** — masked to last 4. The regex matches `ACCT 1234567890`, `Account: 1234567890`, etc.
- **Birthdates** — truncated to the 4-digit year. The `context == "birth"` condition only triggers on dates associated with a birth (DOB, "born", etc.) — other dates in the filing (hearings, transaction dates) pass through.
- **Minors' names** — replaced with initials. The `context == "minor"` condition relies on Philter detecting minor-related context (e.g., "minor child", "the minor", "juvenile"). For high-precision deployments, also configure a custom dictionary of known minor names.

## When to use this

- **Civil complaints and answers**
- **Motions and supporting declarations** filed with personal information from parties, witnesses, or third parties
- **Discovery responses being filed with the court** (note: most discovery is *served* between parties and not filed; only filed discovery is in scope)
- **Trial and pretrial submissions** that include the protected categories
- **Any document filed in a U.S. district court civil case** that originated outside the court system

Specialized federal proceedings have their own rules that supersede FRCP 5.2:

- **Bankruptcy** — use [`rule-9037-bankruptcy`](../rule-9037-bankruptcy/) instead.
- **Criminal** — Federal Rule of Criminal Procedure 49.1 (similar but not identical scope).
- **Immigration / administrative** — court-specific rules.

## When to customize

- **Account number format.** The default `\bACCT[\s:#]*\d{6,}\b` is illustrative. Replace with the specific patterns your case management system uses.
- **TIN format.** The default matches the `XX-XXXXXXX` EIN format. ITINs follow `9XX-XX-XXXX` and are caught by the SSN filter (since they share the SSN format).
- **Minor detection.** If your filings have a structured field for minor names, add a custom `section` filter to redact the entire section content.
- **Per-rule overrides.** FRCP 5.2(d) allows filing unredacted documents under seal with court permission. This policy assumes you want full redaction — if you're preparing a filing for the protected order, use a less aggressive variant or pass through unmodified.
- **Court-specific local rules.** Many district courts have local rules that supplement FRCP 5.2 (e.g., redacting witness home addresses, redacting alien-registration numbers in immigration-related matters). Layer those on top of this baseline.

## Compliance notes

- **Federal Rule of Civil Procedure 5.2** has been in effect since December 1, 2007. It applies to all documents filed with the U.S. district courts in civil matters.
- This policy implements only the **privacy-protection redactions** required by FRCP 5.2(a). It does **not** handle the additional sealing or restricted-access provisions of FRCP 5.2(d) (motion to file under seal) or 5.2(e) (additional protections by court order).
- FRCP 5.2(b) provides several **exemptions** — the redaction requirements do not apply to financial-account numbers identifying the property allegedly subject to forfeiture, the record of an administrative or agency proceeding, the official record of a state-court proceeding, the record of a court or tribunal if not subject to the privacy-protection rule, or filings covered by 5.2(c) (Social Security or immigration-related cases). Configure exemption handling in your filing workflow; this policy does not automatically detect those contexts.
- Attorneys remain responsible for the accuracy of their filings. This policy is a tool to reduce manual redaction work, not a substitute for attorney review.

## References

- [FRCP 5.2 — Privacy Protection For Filings Made with the Court](https://www.law.cornell.edu/rules/frcp/rule_5.2)
- [FRBP 9037 — Privacy Protection For Filings Made with the Court (bankruptcy)](https://www.law.cornell.edu/rules/frbp/rule_9037)
- [Federal Rule of Criminal Procedure 49.1 — Privacy Protection For Filings Made with the Court](https://www.law.cornell.edu/rules/frcrmp/rule_49.1)
- [Judiciary Privacy Policy and Public Access to Electronic Case Files](https://www.uscourts.gov/rules-policies/judiciary-policies/privacy-policy-electronic-case-files)
