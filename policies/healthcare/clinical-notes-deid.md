---
title: "Clinical Notes De-Identification (Date-Shifted)"
slug: "clinical-notes-deid"
category: "healthcare"
tags: ["HIPAA", "PHI", "clinical notes", "date shifting", "research"]
author: "Philterd"
version: "1.0.0"
updated: "2026-05-18"
philterCompatibility: ">=3.0.0"
useCase: "De-identify clinical notes for research, ML training, or analytics — preserving temporal relationships via per-patient date shifting."
entities: ["NAME", "PROVIDER", "DATE", "AGE", "PHONE", "SSN", "EMAIL", "HOSPITAL", "MRN"]
exampleInput: "Dr. Garcia saw Mr. Smith (MRN 47291) on 2025-03-14 for follow-up of his 2024-12-08 admission. Patient is 72 years old."
exampleOutput: "[PROVIDER] saw [PATIENT] ([MRN]) on 2025-04-26 for follow-up of his 2025-01-19 admission. Patient is 72 years old."
---

## What this policy does

Tailored for **research and ML use cases** where you need patient privacy *and* the temporal structure of clinical events to remain analyzable. Differs from the strict HIPAA Safe Harbor policy in three ways:

1. **Per-patient date shifting** instead of full date redaction. Each patient's dates are shifted by the same random offset (±90 days), preserving intervals between events while breaking linkage to the actual calendar dates.
2. **Replacement tokens instead of full redaction** — `[PATIENT]`, `[PROVIDER]`, `[FACILITY]` — makes the text more readable for human reviewers and easier for downstream NLP.
3. **Confidence-gated name detection** (`confidence > 60`) reduces over-redaction of common English words that Philter's NER occasionally misfires on in clinical text.

Ages under 90 are preserved (clinically relevant). Ages 90+ get the `[AGE>89]` token per HIPAA Safe Harbor §164.514(b)(2)(i)(C).

## When to customize

- **Date shift window.** ±90 days works for most cohort studies. For oncology timelines or longitudinal studies that span years, widen the window to ±365 or more.
- **Replacement tokens.** If your downstream pipeline expects specific tokens (e.g., spaCy's `PERSON` or HuggingFace's `[NAME]`), edit the `redactionFormat` fields.
- **Confidence threshold.** `> 60` is conservative. For higher-recall (catch more names at the cost of more false positives), lower to `> 40`. For higher-precision research datasets where false positives are worse than false negatives, raise to `> 80`.
- **MRN regex.** Same caveat as the Safe Harbor policy — adjust for your EHR's format.

## When NOT to use this policy

- **For publication or sharing outside your covered entity.** This policy is *more* permissive than Safe Harbor — it keeps year-month-day structure (just shifted) and uses semantic tokens that are easier to re-identify than full redaction. For external sharing, use [hipaa-safe-harbor.json](../healthcare/hipaa-safe-harbor.md) instead.
- **For PCI or financial workloads.** Use the finance/ policies instead.

## Compliance notes

Date shifting is a recognized de-identification technique under the [HHS Expert Determination method](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html#expert), but it does NOT meet HIPAA Safe Harbor on its own. Sharing data redacted with this policy outside the covered entity requires a qualified statistician's certification under 45 CFR 164.514(b)(1).

For internal research use within the covered entity, this policy + an executed Business Associate Agreement (where applicable) is generally sufficient. Confirm with your IRB or compliance office.

## References

- [HHS Guidance on Expert Determination](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html#expert)
- [Date Shifting Best Practices (NIST SP 800-188 draft)](https://csrc.nist.gov/publications/detail/sp/800-188/draft)
