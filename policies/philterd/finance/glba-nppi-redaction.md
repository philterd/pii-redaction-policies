---
title: "GLBA Nonpublic Personal Information (NPPI) Redaction"
slug: "glba-nppi-redaction"
category: "finance"
tags: ["GLBA", "NPPI", "financial privacy", "Safeguards Rule", "15 USC 6801", "banking"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-05-18"
philterCompatibility: ">=3.0.0"
useCase: "Redact Nonpublic Personal Information (NPPI) from financial customer records under the Gramm-Leach-Bliley Act (15 USC 6801-6809)."
entities: ["CUSTOMER", "SSN", "CREDIT_CARD", "IBAN", "DATE", "PHONE", "EMAIL", "ADDRESS", "LICENSE", "PASSPORT", "RTN", "ACCOUNT", "LOAN"]
exampleInput: "Customer Robert Chen (SSN 123-45-6789, DOB 1980-06-15) opened account 1234567890 with routing 021000021. Mortgage MTG-2024-887." 
exampleOutput: "Customer [CUSTOMER] (SSN [REDACTED-SSN], DOB 1980) opened account ******7890 with routing [REDACTED-RTN]. [REDACTED-LOAN]."
---

## What this policy does

Removes Nonpublic Personal Information (NPPI) &mdash; the category of customer financial data protected by the [Gramm-Leach-Bliley Act](https://www.law.cornell.edu/uscode/text/15/chapter-94) (GLBA) &mdash; from financial-services records.

NPPI is **broader than PCI DSS scope**. PCI focuses specifically on cardholder data; GLBA covers any personally identifiable financial information a financial institution obtains in connection with providing a financial service:

- Account balances and transaction history
- Deposit, withdrawal, and payment patterns
- Loan and credit history
- Investment holdings
- Plus traditional PII (names, SSNs, addresses) when collected in a financial context

This policy targets the identifier fields:

- **Customer names** &mdash; redacted to `[CUSTOMER]` (confidence-gated)
- **SSNs** &mdash; fully redacted
- **Credit card numbers** &mdash; masked to last 4 visible
- **IBANs** &mdash; masked to last 4
- **Birthdates** &mdash; truncated to year only when context indicates a birth date
- **Phone, email, address** &mdash; redacted
- **Driver's license, passport numbers** &mdash; redacted
- **Bank routing numbers (ABA RTNs)** &mdash; redacted
- **Account numbers** &mdash; masked to last 4 visible
- **Loan / mortgage / note numbers** &mdash; redacted

It preserves transaction amounts, dates of transactions (non-birth), and analytical fields by default &mdash; these are usually the operational reason the records are being processed in the first place.

## When to use this

- **Sharing customer data with a third-party processor** (loan servicers, payment processors, collections agencies, marketing analytics vendors)
- **Internal analytics across business units** where the analytics team shouldn't see fully-identified customer records
- **Training fraud-detection or credit-risk models** on real transaction data
- **Audit response** where regulators or auditors need representative records without specific customer identification
- **Document retention** where records must be kept beyond active use but identifying details are no longer needed

## When to customize

- **Customer name handling.** Default redacts names with `[CUSTOMER]` tokens. For internal use cases where the customer name is operationally needed (e.g., case management, dispute resolution), preserve names by removing the `personsName` entry &mdash; or build a parallel "internal-only" variant.
- **Date of birth.** Default truncates to year only when context indicates a birth date. For research use cases needing age-band analysis, year is enough. For pure de-identification, switch to full REDACT.
- **Address granularity.** Default fully redacts addresses. For analytics where geographic region matters, use a REPLACE strategy with `[STATE]` or `[REGION]` (Philter's `state` and custom identifiers can help here).
- **Account / routing / loan number formats.** Defaults are generic. Replace with your core banking system's actual patterns &mdash; especially loan numbers, which vary widely (mortgages, auto loans, HELOCs, commercial loans often have different format conventions).
- **Transaction amounts.** Not redacted by default &mdash; they're analytically valuable and aren't NPPI on their own. For datasets where customer-amount linkability is the concern, add an `identifier` rule for currency patterns.
- **Wealth-management records.** Investment holdings and balances can be NPPI. If your records include them, decide whether the analytical purpose needs them; if not, add custom redaction.

## GLBA vs PCI DSS &mdash; pick the right policy

These regimes cover overlapping but distinct data:

|  | PCI DSS | GLBA |
|---|---|---|
| Scope | Cardholder data (PAN, CVV, etc.) | All NPPI (financial PII) |
| Trigger | Accepting / processing / storing cards | Being a "financial institution" under GLBA |
| Strictest requirement | No storage of Sensitive Authentication Data post-auth | Reasonable safeguards for customer information |
| Companion policy here | [pci-dss-scope-reduction.json](../finance/pci-dss-scope-reduction.md) | (this policy) |

In practice, most financial institutions need both. Use the PCI policy for systems that touch cards specifically; use this GLBA policy for the broader customer-data systems. They can be stacked on the same document if the document contains both types of data.

## Compliance notes

- **15 USC 6801-6809** &mdash; the GLBA statute
- **16 CFR Part 314** &mdash; the FTC's Safeguards Rule (substantially updated 2022) requires financial institutions to maintain a written Information Security Program with reasonable safeguards for customer information
- **16 CFR Part 313** &mdash; the Privacy Rule requires annual privacy notices and opt-out for certain disclosures of NPPI to non-affiliated third parties
- **State financial-privacy laws** may impose additional or stricter requirements:
  - California (CCPA / CPRA, plus the California Financial Information Privacy Act)
  - Nevada (NRS Chapter 603A)
  - New York (NYDFS Cybersecurity Regulation 23 NYCRR Part 500)
  - Massachusetts (201 CMR 17.00)
  
  This policy is GLBA-baseline; layer state-specific policies on top as needed.
- **Bank Secrecy Act (BSA) and AML records** have specific retention and reporting requirements that may conflict with aggressive redaction. Coordinate with your BSA officer before redacting records that fall under BSA recordkeeping obligations.

## References

- [Gramm-Leach-Bliley Act (15 USC § 6801 et seq.)](https://www.law.cornell.edu/uscode/text/15/chapter-94)
- [FTC Safeguards Rule (16 CFR Part 314)](https://www.ecfr.gov/current/title-16/chapter-I/subchapter-C/part-314)
- [FTC Privacy Rule (16 CFR Part 313)](https://www.ecfr.gov/current/title-16/chapter-I/subchapter-C/part-313)
- [FTC GLBA Compliance Guidance](https://www.ftc.gov/business-guidance/privacy-security/gramm-leach-bliley-act)
- [Companion blueprint &mdash; PCI DSS and GLBA pipeline patterns](https://philterd.ai/blog/redaction-for-financial-services-pci-dss-glba-real-world-pipelines/)
