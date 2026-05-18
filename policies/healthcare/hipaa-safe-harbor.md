---
title: "HIPAA Safe Harbor De-Identification"
slug: "hipaa-safe-harbor"
category: "healthcare"
tags: ["HIPAA", "Safe Harbor", "PHI", "45 CFR 164.514", "de-identification"]
author: "Philterd"
version: "1.0.0"
updated: "2026-05-18"
philterCompatibility: ">=3.0.0"
useCase: "Remove all 18 HIPAA Safe Harbor identifiers from clinical text per 45 CFR 164.514(b)(2)."
entities: ["NAME", "AGE", "DATE", "PHONE", "EMAIL", "SSN", "MRN", "ACCOUNT", "URL", "IP", "ZIP", "HOSPITAL", "CITY", "COUNTY"]
exampleInput: "Patient John Smith (DOB 1985-04-12, MRN 47291) was seen at Mercy Hospital on 2025-03-14. Call (555) 123-4567 with questions."
exampleOutput: "Patient {{{REDACTED-name}}} (DOB {{{REDACTED-date}}}, {{{REDACTED-MRN}}}) was seen at {{{REDACTED-hospital}}} on {{{REDACTED-date}}}. Call {{{REDACTED-phone-number}}} with questions."
---

## What this policy does

Removes the 18 protected health identifiers enumerated under the HIPAA Safe Harbor method ([45 CFR 164.514(b)(2)](https://www.ecfr.gov/current/title-45/subtitle-A/subchapter-C/part-164/subpart-E/section-164.514#p-164.514(b)(2))):

| # | Identifier | How this policy handles it |
|---|---|---|
| 1 | Names | `personsName` → REDACT |
| 2 | Geographic subdivisions smaller than a state | `city`, `county` → REDACT; `zipCode` → truncate to 3 digits |
| 3 | All elements of dates (except year) for dates directly related to an individual | `date` → REDACT (covers admission, discharge, birth, death) |
| 4 | Telephone numbers | `phoneNumber` → REDACT |
| 5 | Fax numbers | `phoneNumber` → REDACT (Philter classifies as phone) |
| 6 | Email addresses | `emailAddress` → REDACT |
| 7 | Social Security numbers | `ssn` → REDACT |
| 8 | Medical record numbers | custom `mrn` identifier → REDACT |
| 9 | Health plan beneficiary numbers | custom `account-number` identifier → REDACT (tune the regex for your plan's format) |
| 10 | Account numbers | custom `account-number` identifier → REDACT |
| 11 | Certificate/license numbers | **needs custom identifier per deployment** |
| 12 | Vehicle identifiers and serial numbers | **add `vin` filter if applicable** |
| 13 | Device identifiers and serial numbers | **add custom identifier per deployment** |
| 14 | Web URLs | `url` → REDACT |
| 15 | IP addresses | `ipAddress` → REDACT |
| 16 | Biometric identifiers | **out of scope for text redaction** |
| 17 | Full-face photos | **out of scope for text redaction** |
| 18 | Any other unique identifying number, characteristic, or code | **add custom identifiers per deployment** |

The `age` filter triggers only on ages **> 89** per Safe Harbor §164.514(b)(2)(i)(C) — ages 90 and above must be aggregated into a single category of "90 or older."

## When to customize

- **MRN format.** The default regex matches `MRN 47291`, `MRN: 47291`, `MRN# 47291` with 5+ digits. If your EHR uses a different prefix (e.g., `HRN`, `PTID`) or a fixed-width format, update the `pattern` field in the custom `mrn` identifier.
- **Account number format.** Same caveat — the default `\bACCT[\s:#]*\d{6,}\b` is illustrative. Replace with your billing system's actual account-number pattern.
- **Date treatment.** Safe Harbor permits keeping the year for non-individual dates. If you need year-only date generalization (e.g., to preserve temporal ordering for cohort analysis), switch the `date` strategy from `REDACT` to a custom replacement format.
- **Geographic granularity.** ZIP codes are truncated to 3 digits (Safe Harbor allows the first 3 ZIP digits if the geographic area covers > 20,000 people). If your dataset includes ZIPs from sparsely-populated regions, tighten further per §164.514(b)(2)(i)(B).
- **Identifiers 11, 13, 18.** Add custom regex `identifiers` for any deployment-specific codes (insurance member IDs, device serial numbers, internal patient identifiers).

## Compliance notes

- This policy implements the **Safe Harbor method** under 45 CFR 164.514(b)(2). The alternative — the **Expert Determination method** under 164.514(b)(1) — requires a qualified statistician's opinion and is out of scope for this policy.
- Safe Harbor compliance also requires that the covered entity have **no actual knowledge** that the residual information could identify an individual (164.514(b)(2)(ii)). Automated redaction does not satisfy that requirement on its own; a human reviewer or risk-assessment process is still needed for production deployments.
- Output dataset is considered de-identified under HIPAA Safe Harbor only after all 18 identifiers are removed *and* the no-actual-knowledge condition is met.

## References

- [45 CFR § 164.514 — Other requirements relating to uses and disclosures of protected health information](https://www.ecfr.gov/current/title-45/subtitle-A/subchapter-C/part-164/subpart-E/section-164.514)
- [HHS Guidance Regarding Methods for De-identification of PHI](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html)
