---
title: "CCPA / CPRA Consumer Privacy Redaction"
slug: "ccpa-consumer-privacy"
category: "general"
tags: ["CCPA", "CPRA", "California", "consumer privacy", "personal information", "sensitive personal information", "privacy"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-06-08"
philterCompatibility: ">=3.0.0"
useCase: "Redact personal information and sensitive personal information as defined by the California Consumer Privacy Act (CCPA/CPRA) from consumer records."
entities: ["NAME", "EMAIL", "PHONE", "ADDRESS", "SSN", "LICENSE", "PASSPORT", "DATE", "CREDIT_CARD", "IP", "MAC", "URL", "STATE_ID", "ACCOUNT"]
exampleInput: "Consumer Maria Garcia (SSN 555-12-3456) of 88 Pine St, San Jose used account 4455667788. Email maria.g@example.com, phone (408) 555-0142, IP 203.0.113.7. CA driver license D1234567."
exampleOutput: "Consumer {{{REDACTED-person}}} (SSN {{{REDACTED-ssn}}}) of {{{REDACTED-streetAddress}}}, San Jose used account ****7788. Email {{{REDACTED-emailAddress}}}, phone {{{REDACTED-phoneNumber}}}, IP {{{REDACTED-ipAddress}}}. CA driver license {{{REDACTED-driversLicense}}}."
---

## What this policy does

Removes **personal information (PI)** and **sensitive personal information (SPI)** as defined by the [California Consumer Privacy Act](https://oag.ca.gov/privacy/ccpa) (CCPA), as amended by the California Privacy Rights Act (CPRA).

The CCPA defines personal information very broadly &mdash; information that identifies, relates to, or could reasonably be linked with a consumer or household ([Cal. Civ. Code § 1798.140(v)](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=1798.140)). The CPRA added a **sensitive personal information** subcategory (§ 1798.140(ae)) covering SSNs, driver's licence / state ID numbers, financial account access, precise geolocation, and similar.

This policy targets:

- **Names** &mdash; redacted (confidence-gated)
- **Email, phone, postal address** &mdash; redacted (identifiers under § 1798.140(v))
- **SSNs, driver's licence, passport, state ID** &mdash; redacted (sensitive personal information)
- **Birthdates** &mdash; truncated to year only when context indicates a birth date
- **Credit card numbers and account numbers** &mdash; masked to last 4 visible (financial-account SPI)
- **IP addresses, MAC addresses, URLs** &mdash; redacted as unique / online identifiers

## When to use this

- **Fulfilling a consumer "right to know" / access request** where another consumer's or household's PI must be redacted from the disclosed records
- **Sharing consumer data with a service provider or contractor** under a CCPA-compliant contract that limits use to business purposes
- **De-identifying data** so it falls outside CCPA scope (§ 1798.140(m)) before analytics or model training
- **Data-broker and advertising pipelines** where opt-out / "Do Not Sell or Share" signals require stripping identifiers
- **Internal analytics across teams** where full consumer identity isn't needed

## When to customize

- **Household linkage.** CCPA covers "household" data. If your records can be re-linked to a household through combinations of non-redacted fields (e.g. address + device), evaluate those combinations &mdash; field-level redaction alone may not de-identify.
- **Precise geolocation.** CPRA treats precise geolocation as SPI. This policy does not detect lat/long or GPS coordinates by default; add a custom identifier if your data contains them.
- **State / consumer ID formats.** The default `state-id` pattern is keyword-anchored. Replace it with the exact California DL/ID format if you only process California records.
- **Name confidence threshold.** Default redacts names above confidence 70. Adjust for precision vs recall.
- **De-identification standard.** To rely on the CCPA's de-identified-data exemption you must also commit to not re-identifying and implement safeguards (§ 1798.140(m)); redaction is a necessary but not sufficient step.

## CCPA/CPRA vs GDPR

Both are broad consumer/data-subject privacy regimes, and the entity coverage overlaps heavily. Key differences for redaction purposes:

|  | CCPA / CPRA | GDPR |
|---|---|---|
| Jurisdiction | California residents | EU/EEA data subjects |
| Unit of protection | Consumer **and household** | Natural person |
| Sensitive subcategory | "Sensitive personal information" (§ 1798.140(ae)) | "Special categories" (Art. 9) |
| Companion policy here | (this policy) | [gdpr-personal-data.json](../general/gdpr-personal-data.md) |

If you operate in both regimes, the [GDPR policy](../general/gdpr-personal-data.md) adds health/special-category detection; the two can be stacked on the same document.

## Compliance notes

- **Cal. Civ. Code § 1798.100 et seq.** &mdash; the CCPA, effective 1 January 2020
- **California Privacy Rights Act (CPRA)** &mdash; amended the CCPA; most provisions effective 1 January 2023, enforced by the California Privacy Protection Agency (CPPA)
- **§ 1798.140(v)** &mdash; definition of personal information
- **§ 1798.140(ae)** &mdash; definition of sensitive personal information
- **§ 1798.140(m)** &mdash; standard for de-identified data (outside CCPA scope)
- This policy is a **baseline starting point**, not legal advice or a de-identification certification. Assess re-identification and household-linkage risk for your specific dataset.

## References

- [California Attorney General &mdash; CCPA](https://oag.ca.gov/privacy/ccpa)
- [California Privacy Protection Agency](https://cppa.ca.gov/)
- [Cal. Civ. Code § 1798.140 (definitions)](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?lawCode=CIV&sectionNum=1798.140)
