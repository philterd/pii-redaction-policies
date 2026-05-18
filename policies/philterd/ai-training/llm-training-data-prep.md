---
title: "LLM Training Data Preparation"
slug: "llm-training-data-prep"
category: "ai-training"
tags: ["AI", "LLM", "fine-tuning", "training data", "RAG", "ingestion"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-05-18"
philterCompatibility: ">=3.0.0"
useCase: "Aggressive PII redaction for documents being fed into LLM training, fine-tuning, or RAG vector stores — preserves semantic structure with type tokens."
entities: ["PERSON", "PHONE", "EMAIL", "SSN", "CARD", "IP", "URL", "PASSPORT", "LICENSE", "IBAN", "ORG", "LOCATION", "ADDRESS"]
exampleInput: "Patient John Smith was treated by Dr. Garcia at Mercy Hospital in Austin, TX. Contact: john@example.com or 555-867-5309."
exampleOutput: "Patient [PERSON] was treated by [PERSON] at [ORG] in [LOCATION], TX. Contact: [EMAIL] or [PHONE]."
---

## What this policy does

Tuned specifically for the AI training and RAG ingestion use case, which has different priorities than other redaction scenarios:

1. **Bias toward over-redaction.** Once data enters model weights or a vector store, it's effectively unrecoverable. Catching a false positive (extra redacted token) is cheap; missing a true positive (PII baked into the model) is expensive. Name confidence threshold is `> 55` (looser than general-purpose) for higher recall.

2. **Semantic tokens, not asterisks.** Replaces PII with `[PERSON]`, `[ORG]`, `[LOCATION]`, etc. — preserves grammatical structure so the model still learns "patient X was treated by physician Y at facility Z" rather than just learning that asterisks appear randomly.

3. **Aggregates similar types.** `physicianName` and `personsName` both map to `[PERSON]`. `hospital` maps to `[ORG]`. Reduces vocabulary fragmentation in the trained model.

## When to use this

- **Pre-training corpus cleanup** for healthcare, finance, legal, or other domain-specific LLMs
- **RAG ingestion pipelines** — redact source documents before chunking and embedding
- **Fine-tuning dataset preparation** — clean conversation logs, support tickets, etc. before SFT
- **Synthetic data generation seed** — strip PII from real examples before using them as templates for generating synthetic training data

## When NOT to use this

- **Production inference output redaction** — too aggressive; will redact things the model legitimately needs (e.g., a chatbot answering "what's the address of your nearest store"). For inference-time redaction, use [Philter AI Proxy](https://philterd.ai/philter-ai-proxy/) with a lighter policy.
- **External data publication** — does not meet HIPAA Safe Harbor (keeps some semantic structure that could enable re-identification). For publication, use [hipaa-safe-harbor.json](../healthcare/hipaa-safe-harbor.md).
- **Legal/court filings** — wrong tool. Use [legal/](../legal/) policies instead.

## When to customize

- **Token vocabulary.** If your training framework expects specific tokens (e.g., spaCy's `PER` and `ORG`, BERT's `[PERSON]`), adjust `redactionFormat` accordingly. Consistency with downstream tokenizer matters.
- **Confidence threshold.** `> 55` is loose. For very large training corpora where false positives are diluted, drop to `> 45` for maximum recall. For smaller datasets where each over-redaction hurts more, raise to `> 70`.
- **Domain-specific entities.** Add custom `identifiers` patterns for entities specific to your domain (drug names, ICD codes, legal citations, ticker symbols). Decide whether to redact or preserve based on whether they're identifying.

## Why this matters

[Beyond Regex: Why General LLMs Fail at PII Discovery](https://philterd.ai/blog/beyond-regex-why-general-llms-fail-at-pii-discovery/) covers the failure modes of relying on the LLM itself to handle PII. The short version: production-grade redaction needs to happen **before** PII reaches the model, not as a post-hoc filter or in-context instruction.

A model trained on un-redacted PII memorizes it. Studies have demonstrated extraction attacks recovering specific phone numbers, addresses, and SSNs from production LLMs trained on web-scraped data. Pre-training redaction is the only reliable defense.

## References

- [Carlini et al., "Extracting Training Data from Large Language Models" (USENIX Security 2021)](https://www.usenix.org/conference/usenixsecurity21/presentation/carlini-extracting)
- [Building a Privacy-Aware RAG System](https://philterd.ai/blog/building-a-privacy-aware-rag-system/)
- [Prompt Engineering for Privacy](https://philterd.ai/blog/prompt-engineering-for-privacy/)
