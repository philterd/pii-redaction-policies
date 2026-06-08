---
title: "GDPR Personal Data Redaction"
slug: "gdpr-personal-data"
category: "general"
tags: ["GDPR", "EU", "personal data", "data protection", "Article 4", "Article 9", "privacy"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-06-08"
philterCompatibility: ">=3.0.0"
useCase: "Redact personal data and special-category data as defined by the EU General Data Protection Regulation (GDPR) from documents and records."
entities: ["NAME", "DATE", "EMAIL", "PHONE", "ADDRESS", "IP", "MAC", "IBAN", "CREDIT_CARD", "PASSPORT", "LICENSE", "MEDICAL_CONDITION", "URL", "NATIONAL_ID", "VAT"]
exampleInput: "Data subject Anna Müller (DOB 1985-04-12) lives at Hauptstraße 5, Berlin. Email anna.mueller@example.de, phone +49 30 123456. IBAN DE89370400440532013000. National Insurance NINO QQ123456C. Diagnosed with asthma."
exampleOutput: "Data subject {{{REDACTED-person}}} (DOB 1985) lives at {{{REDACTED-streetAddress}}}, Berlin. Email {{{REDACTED-emailAddress}}}, phone {{{REDACTED-phoneNumber}}}. IBAN ****************3000. {{{REDACTED-NATIONAL-ID}}}. Diagnosed with {{{REDACTED-medicalCondition}}}."
---

## What this policy does

Removes **personal data** &mdash; any information relating to an identified or identifiable natural person under [Article 4(1) of the GDPR](https://gdpr-info.eu/art-4-gdpr/) &mdash; from documents and records, with extra attention to the **special categories of personal data** in [Article 9](https://gdpr-info.eu/art-9-gdpr/) (which includes health data).

The GDPR's definition of personal data is deliberately broad. It explicitly names online identifiers (IP addresses, device identifiers) alongside the traditional direct identifiers. This policy targets:

- **Names** &mdash; redacted (confidence-gated)
- **Birthdates** &mdash; truncated to year only when context indicates a birth date; other dates pass through
- **Email, phone, postal address** &mdash; redacted
- **IP addresses and MAC addresses** &mdash; redacted as Article 4 online identifiers
- **IBANs and credit card numbers** &mdash; masked to last 4 visible
- **Passport and driver's licence numbers** &mdash; redacted
- **Health / medical conditions** &mdash; redacted as Article 9 special-category data
- **URLs** &mdash; redacted (may carry identifiers in query strings)
- **National identification numbers** (NINO, BSN, personnummer, NIF/NIE, codice fiscale, TIN) &mdash; redacted
- **VAT numbers** &mdash; redacted

## When to use this

- **Transferring records to a processor or third country** where a Data Processing Agreement requires minimising identifiable data
- **Responding to a Subject Access Request (SAR)** where third parties' personal data must be redacted from the disclosed copy
- **Sharing data for analytics or research** under the GDPR's data-minimisation principle ([Article 5(1)(c)](https://gdpr-info.eu/art-5-gdpr/))
- **Pseudonymisation workflows** ([Article 4(5)](https://gdpr-info.eu/art-4-gdpr/)) where direct identifiers are stripped before further processing
- **Training or fine-tuning models** on data that originated in the EU/EEA

## When to customize

- **National ID formats.** The default `national-id` pattern is keyword-anchored and intentionally broad to span member states. For a single jurisdiction, replace it with that country's exact format (e.g. a precise UK NINO or Dutch BSN regex) to reduce false positives and negatives.
- **Name confidence threshold.** Default redacts names above confidence 70. Lower it for higher recall (more aggressive redaction), raise it for higher precision.
- **Date of birth.** Default truncates to year on birth context. For full pseudonymisation switch to `REDACT`; for age-band research, year is usually sufficient.
- **Special categories.** Article 9 also covers racial/ethnic origin, political opinions, religious beliefs, trade-union membership, genetic and biometric data, and sexual orientation. Only health (`medicalCondition`) is detected automatically here; add custom identifiers or dictionaries for the other categories if your documents contain them.
- **Pseudonymisation vs anonymisation.** Redaction alone may still leave indirectly-identifying data. True anonymisation (data outside GDPR scope) requires assessing re-identification risk across the whole record, not just removing these fields.

## Compliance notes

- **Regulation (EU) 2016/679 (GDPR)** &mdash; in force since 25 May 2018
- **Article 4** defines personal data, pseudonymisation, and online identifiers
- **Article 5** sets the data-minimisation and storage-limitation principles this policy supports
- **Article 9** governs special categories of personal data (health data is detected here)
- **UK GDPR + Data Protection Act 2018** mirror these definitions for the United Kingdom post-Brexit; this policy applies equally as a baseline
- This policy is a **baseline starting point**, not a determination of lawful basis, and does not by itself achieve anonymisation under [Recital 26](https://gdpr-info.eu/recitals/no-26/). Always assess re-identification risk for your specific dataset.

## References

- [GDPR full text (gdpr-info.eu)](https://gdpr-info.eu/)
- [Article 4 &mdash; Definitions](https://gdpr-info.eu/art-4-gdpr/)
- [Article 9 &mdash; Special categories of personal data](https://gdpr-info.eu/art-9-gdpr/)
- [EDPB guidance on pseudonymisation and anonymisation](https://www.edpb.europa.eu/our-work-tools/general-guidance/guidelines-recommendations-best-practices_en)
