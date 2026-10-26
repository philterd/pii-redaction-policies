---
title: "HIPAA Safe Harbor De-Identification"
slug: "hipaa-safe-harbor"
category: "healthcare"
tags: ["HIPAA", "Safe Harbor", "PHI", "45 CFR 164.514", "de-identification"]
author: "Philterd"
creator: "philterd"
version: "2.0.1"
updated: "2026-10-26"
philterCompatibility: ">=4.0.0"
useCase: "A starting point for HIPAA Safe Harbor de-identification of clinical text per 45 CFR 164.514(b)(2)."
entities: ["NAME", "AGE", "DATE", "PHONE", "EMAIL", "SSN", "MRN", "ACCOUNT", "URL", "IP", "MAC_ADDRESS", "VIN", "DRIVERS_LICENSE", "PASSPORT", "STREET_ADDRESS", "ZIP", "HOSPITAL", "CITY", "COUNTY"]
exampleInput: "Patient John Smith (DOB 1985-04-12, MRN 47291) lives at 1234 Oak Street, Austin, TX 78701. Phone: (555) 123-4567."
exampleOutput: "Patient {{{REDACTED-name}}} (DOB {{{REDACTED-date}}}, {{{REDACTED-MRN}}}) lives at {{{REDACTED-street-address}}}, {{{REDACTED-city}}}, TX 787**. Phone: {{{REDACTED-phone-number}}}."
---

## What this policy does

Designed to redact the text-based identifiers enumerated under the HIPAA Safe Harbor method ([45 CFR 164.514(b)(2)](https://www.ecfr.gov/current/title-45/subtitle-A/subchapter-C/part-164/subpart-E/section-164.514#p-164.514(b)(2))). Some require a custom identifier for your deployment, as the table below shows:

| # | Identifier | How this policy handles it |
|---|---|---|
| 1 | Names | `pheyes` (the deployment's PhEye model) → REDACT |
| 2 | Geographic subdivisions smaller than a state | `streetAddress`, `city`, `county` → REDACT; `zipCode` → truncate to 3 digits, or REDACT for sparsely populated 3-digit areas (see below); `hospital` → REDACT for hospitals in its dictionary |
| 3 | All elements of dates (except year) for dates directly related to an individual | `date` → REDACT (covers admission, discharge, birth, death); `age` → REDACT (see below) |
| 4 | Telephone numbers | `phoneNumber` → REDACT |
| 5 | Fax numbers | `phoneNumber` → REDACT (Philter classifies as phone) |
| 6 | Email addresses | `emailAddress` → REDACT |
| 7 | Social Security numbers | `ssn` → REDACT |
| 8 | Medical record numbers | custom `mrn` identifier → REDACT |
| 9 | Health plan beneficiary numbers | custom `account-number` identifier → REDACT (tune the regex for your plan's format) |
| 10 | Account numbers | custom `account-number` identifier → REDACT |
| 11 | Certificate/license numbers | `driversLicense`, `passportNumber` → REDACT; professional licenses **need a custom identifier per deployment** |
| 12 | Vehicle identifiers and serial numbers | `vin` → REDACT; license plates **need a custom identifier per deployment** |
| 13 | Device identifiers and serial numbers | `macAddress` → REDACT; serial numbers **need a custom identifier per deployment** |
| 14 | Web URLs | `url` → REDACT |
| 15 | IP addresses | `ipAddress` → REDACT |
| 16 | Biometric identifiers | **out of scope for text redaction** |
| 17 | Full-face photos | **out of scope for text redaction** |
| 18 | Any other unique identifying number, characteristic, or code | **add custom identifiers per deployment** |

Ages: Safe Harbor requires ages over 89 to be aggregated into a single "90 or older" category. Policy conditions cannot compare an age numerically, so this policy redacts every age it finds. That removes more than Safe Harbor requires.

ZIP codes: Safe Harbor allows the first three digits of a ZIP code only when that 3-digit area has more than 20,000 people. This policy redacts ZIP codes beginning with 036, 059, 063, 102, 203, 205, 369, 556, 692, 790, 821, 823, 830, 831, 878, 879, 884, 890, and 893, which combines the areas at or below that threshold in the 2000 and 2010 Census. Check the list against current Census data before relying on it. Other ZIP codes are truncated to three digits, so `78701` becomes `787**`.

`streetAddress` and `zipCode` have a higher `priority` than the other filters, so a house number or ZIP code is not redacted as a driver's license number.

## Hospital names

The `hospital` filter matches hospitals by name from a dictionary, so it misses hospitals not in that list. To find hospital names in free text, run the PhEye hospitals model ([`philterd/ph-eye-hospitals`](https://hub.docker.com/r/philterd/ph-eye-hospitals)) and add a second entry to `pheyes`:

```json
{
  "phEyeConfiguration": {
    "endpoint": "http://ph-eye-hospitals:5000/",
    "labels": ["hospital"]
  },
  "phEyeFilterStrategies": [
    { "strategy": "REDACT", "redactionFormat": "{{{REDACTED-%t}}}" }
  ]
}
```

Set `endpoint` to where the model runs. Philter refuses a policy that names a PhEye endpoint other than `PHEYE_ENDPOINT` unless an administrator lists it in `PHEYE_ALLOWED_ENDPOINTS`.

## When to customize

- **MRN format.** The default regex matches `MRN 47291`, `MRN: 47291`, `MRN# 47291` with 5+ digits. If your EHR uses a different prefix (e.g., `HRN`, `PTID`) or a fixed-width format, update the `pattern` field in the custom `mrn` identifier.
- **Account number format.** The default `\bACCT[\s:#]*\d{6,}\b` is illustrative. Replace it with your billing system's actual account-number pattern.
- **Date treatment.** Safe Harbor permits keeping the year for non-individual dates. If you need year-only date generalization (e.g., to preserve temporal ordering for cohort analysis), switch the `date` strategy from `REDACT` to a custom replacement format.
- **Identifiers 11, 12, 13, 18.** Add custom regex `identifiers` for any deployment-specific codes (professional license numbers, license plates, insurance member IDs, device serial numbers, internal patient identifiers).

## Known limitations

- The city filter can match ordinary words, such as "Call" or "Driver", and redact them as cities.
- Detection is probabilistic. Validate the policy's output against a sample of your own records before relying on it.

## Compliance notes

- This policy implements the **Safe Harbor method** under 45 CFR 164.514(b)(2). The alternative, the **Expert Determination method** under 164.514(b)(1), requires a qualified statistician's opinion and is out of scope for this policy.
- Safe Harbor compliance also requires that the covered entity have **no actual knowledge** that the residual information could identify an individual (164.514(b)(2)(ii)). Automated redaction does not satisfy that requirement on its own; a human reviewer or risk-assessment process is still needed for production deployments.
- Output dataset is considered de-identified under HIPAA Safe Harbor only after all 18 identifiers are removed *and* the no-actual-knowledge condition is met.

## References

- [45 CFR § 164.514: Other requirements relating to uses and disclosures of protected health information](https://www.ecfr.gov/current/title-45/subtitle-A/subchapter-C/part-164/subpart-E/section-164.514)
- [HHS Guidance Regarding Methods for De-identification of PHI](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html)

## Using this policy with Phileas

The name filter names `ph-eye-pii-en-small`, the model bundled with Philter 4.0. With Phileas, set its `modelPath` to the directory of a downloaded copy of the model, [philterd/ph-eye-pii-en-small](https://huggingface.co/philterd/ph-eye-pii-en-small).
