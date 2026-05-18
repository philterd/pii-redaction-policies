---
title: "PCI DSS Scope Reduction"
slug: "pci-dss-scope-reduction"
category: "finance"
tags: ["PCI DSS", "cardholder data", "PAN", "scope reduction", "Req 3.4"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-05-18"
philterCompatibility: ">=3.0.0"
useCase: "Strip cardholder data (PAN, CVV, expiration) from logs, transcripts, and tickets to reduce PCI DSS scope per Requirement 3.4."
entities: ["CREDIT_CARD", "IBAN", "SSN", "CVV", "EXPIRATION"]
exampleInput: "Customer paid with card 4532-1234-5678-9010 expires 12/27, CVV 845. Routing IBAN GB82WEST12345698765432 charged $499."
exampleOutput: "Customer paid with card ****-****-****-9010 expires [REDACTED-EXP], CVV [REDACTED-CVV]. Routing IBAN ********************5432 charged $499."
---

## What this policy does

Targets the data that pulls systems into PCI DSS audit scope:

- **Primary Account Numbers (PANs)** — masked to leave only the last 4 digits visible, satisfying PCI DSS Requirement 3.4 ("PAN, at minimum, is rendered unreadable anywhere it is stored").
- **CVV / CVC / CSC** — fully redacted. PCI DSS Requirement 3.2 prohibits storing sensitive authentication data after authorization, even if encrypted.
- **Expiration dates** — fully redacted (not strictly required but common in scope-reduction patterns).
- **IBANs** — masked to last 4 digits.
- **SSNs** — fully redacted (often co-occur in financial documents and are independent PII).

`onlyValidCreditCards: true` means Philter requires a valid Luhn checksum before treating a 13–19 digit sequence as a PAN. This dramatically reduces false positives on things like order numbers, tracking IDs, and customer reference codes.

## When to use this

The most common deployment patterns:

- **Application logs** — pre-ingest redaction before logs hit Splunk, Datadog, Elastic, etc. Removes those log indexers from PCI scope.
- **Call-center transcripts** — see also [contact-center/pci-call-recording-transcripts.json](../contact-center/) for a more aggressive variant tuned for spoken-aloud numbers.
- **Customer support tickets** — Zendesk, Salesforce Service Cloud, Freshdesk tickets where agents accidentally paste card numbers.
- **Email archives** — bulk de-scope email systems that occasionally receive cardholder data.

## When to customize

- **Visible digits.** Last 4 is the PCI minimum. Some workflows (chargebacks, dispute investigations) need first 6 + last 4 — adjust `leaveCharacters` and the masking strategy accordingly, but verify with your QSA.
- **Routing numbers and account numbers.** US bank routing numbers (9-digit ABA RTNs) and account numbers aren't covered by default. Add custom `identifiers` patterns if your data contains them.
- **Currency amounts.** This policy intentionally preserves dollar amounts — they're not PCI-sensitive and usually have business value. If your data also needs amounts redacted (e.g., for cross-customer training data), add a custom identifier.

## Compliance notes

- **PCI DSS Requirement 3.4** allows several rendering methods: one-way hash, truncation, index tokens, or strong cryptography. This policy uses **truncation** (mask all but last 4) — the lowest-friction option for downstream readability.
- **Requirement 3.2** prohibits storing sensitive authentication data (full track data, CAV2/CVC2/CVV2/CID, PINs/PIN blocks) after authorization. This policy redacts CVVs fully to support that.
- **De-scoping caveats.** Removing PAN from a system doesn't *automatically* take it out of PCI scope. You also need: documented data flow showing PAN can't re-enter; segmentation controls; periodic validation. Treat this policy as one input to scope-reduction, not the whole answer.

## References

- [PCI DSS v4.0 Quick Reference Guide](https://www.pcisecuritystandards.org/document_library)
- [PCI DSS Scoping and Network Segmentation Information Supplement](https://www.pcisecuritystandards.org/document_library/?category=info_sup)
