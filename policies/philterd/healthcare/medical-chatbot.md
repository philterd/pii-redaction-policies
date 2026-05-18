---
title: "Medical Chatbot — User Input Redaction"
slug: "medical-chatbot"
category: "healthcare"
tags: ["HIPAA", "PHI", "chatbot", "LLM", "conversational AI", "RAG"]
author: "Philterd"
creator: "philterd"
version: "1.0.0"
updated: "2026-05-18"
philterCompatibility: ">=3.0.0"
useCase: "Redact PHI from user messages to a healthcare chatbot before they reach the LLM — preserves clinical meaning while removing identifiers."
entities: ["PERSON", "AGE", "DATE", "PHONE", "EMAIL", "SSN", "ADDRESS", "ZIP", "IP", "FACILITY", "PROVIDER", "MRN", "INSURANCE_ID"]
exampleInput: "Hi, I'm worried about my mom Linda Chen — she's 72, lives at 1234 Oak St in Austin TX 78701, and her MRN at Mercy Hospital is 47291. Her blood pressure was 165/95 this morning."
exampleOutput: "Hi, I'm worried about my mom [PERSON] — she's 72, lives at [REDACTED-ADDRESS] in [REDACTED-ADDRESS] 787, and her [REDACTED-MRN] at [FACILITY] is . Her blood pressure was 165/95 this morning."
---

## What this policy does

Designed for the **specific failure mode** of healthcare chatbots: users type conversational messages that mix clinical context (the thing you want the chatbot to act on) with personally identifying details (the thing you don't want sitting in your LLM provider's logs, training data, or RAG vector store).

The policy preserves clinical meaning while stripping identifiers:

- **Personal names** → `[PERSON]` tokens (confidence threshold lowered to `> 50` because chat messages are short and context-poor — names are harder to detect with high confidence)
- **Ages ≤ 89** → **preserved** (clinically relevant; "she's 72 with hypertension" is the actual question)
- **Ages > 89** → `[AGE>89]` per HIPAA Safe Harbor §164.514(b)(2)(i)(C)
- **Dates** → fully redacted (even seemingly innocuous "last Tuesday" gets caught when written as a date)
- **Addresses, ZIP codes** → redacted (ZIP truncated to 3 digits)
- **Phone, email, IP, SSN** → fully redacted
- **Facility names, provider names** → replaced with `[FACILITY]` / `[PROVIDER]` (preserves the structural fact that a facility/provider was mentioned, without identifying which one)
- **MRN, insurance/member IDs** → custom regex patterns, fully redacted

**What's deliberately preserved:**

- Clinical observations: "blood pressure was 165/95", "her A1C is 7.2"
- Medications: "she's on lisinopril and metformin"
- Symptoms: "chest pain for 3 days", "shortness of breath when walking"
- Relative time references: "last week", "for the past 3 months" (only specific dates are redacted)
- Conditions and diagnoses: "she has type 2 diabetes"

Without these, the chatbot can't answer the user's actual question. The whole point of a healthcare chatbot is to engage with clinical content — just not with the identifying details around it.

## When to use this

- **Healthcare consumer chatbots** (symptom checkers, post-discharge follow-up, medication reminders, patient education)
- **Provider-facing clinical assistants** where the user types free-text questions and the system needs to call an external LLM
- **RAG systems serving healthcare queries** where the user query may itself contain PHI
- **Telemedicine intake flows** where free-text fields capture clinical history
- **Pair with [Philter AI Proxy](https://philterd.ai/philter-ai-proxy/)** to drop in as a transparent middleware between your application and the LLM provider

## When NOT to use this

- **For training a model on user messages.** This policy preserves enough clinical detail to be useful in real-time, but that detail is also potentially re-identifiable in aggregate. For training data, use [llm-training-data-prep.json](../../philterd/ai-training/llm-training-data-prep.md), which is more aggressive.
- **For sharing transcripts externally as de-identified.** Same reason. Use [hipaa-safe-harbor.json](./hipaa-safe-harbor.md) for external sharing.
- **For non-conversational clinical text.** For long-form clinical notes, [clinical-notes-deid.json](./clinical-notes-deid.md) (with date-shifting) is better.

## When to customize

- **Name confidence threshold.** Default `> 50` is loose, reflecting the short-context reality of chat messages. If your chatbot gets a lot of capitalized common words misclassified as names, raise to `> 65`. If you're missing names that humans would obviously spot, lower to `> 40`.
- **Token vocabulary.** Default uses bracketed tokens (`[PERSON]`, `[FACILITY]`). If your downstream LLM is fine-tuned to expect specific tokens (`<patient>`, `<<NAME>>`), adjust the `redactionFormat` fields.
- **Insurance-ID regex.** The default `\b(?:member|policy|insurance|plan)[\s-]?(?:id|number|#)[\s:#]*[A-Z0-9-]{6,}\b` is conservative. Update with your network's actual ID format if known.
- **MRN regex.** Same caveat as other healthcare policies — adjust for your EHR's format.
- **Relative dates.** This policy doesn't redact relative time references like "yesterday" or "last week" because Philter's `date` filter only catches structured dates. If your messages include date-mentioning patterns Philter doesn't catch, add custom identifier regex.

## Architectural pattern

```
user message → [Philter (this policy)] → LLM provider → [Philter (output policy)] → user
```

The output-side Philter policy is usually lighter (the LLM shouldn't *generate* PHI, but defense-in-depth is worth the latency). Common pattern is to use a smaller, faster Philter configuration for the output side and the full medical-chatbot policy for the input side.

See [Building a Privacy-Aware RAG System](https://philterd.ai/blog/building-a-privacy-aware-rag-system/) for a full architecture write-up, and [Prompt Engineering for Privacy](https://philterd.ai/blog/prompt-engineering-for-privacy/) for the prompt-level patterns that complement input-side redaction.

## Compliance notes

- This policy is for **real-time message redaction**, not for de-identifying records under HIPAA Safe Harbor. The output may still constitute PHI under HIPAA (because residual quasi-identifiers exist) — treat the messages and their LLM responses as PHI for the purposes of access controls, audit logging, and BAA scope.
- If your chatbot is provided by a covered entity OR a business associate, the LLM provider you call **needs a BAA**. Major providers (Anthropic, OpenAI, AWS Bedrock, Azure OpenAI) offer BAAs under specific commercial agreements. Verify before sending PHI — even redacted PHI — to the model.
- Pair this policy with documented logging redaction. Your application logs of the input messages (pre-redaction) are themselves PHI, so they need to live in HIPAA-eligible storage with the same controls as any other clinical system.

## References

- [Building a HIPAA-Compliant Medical Chatbot](https://philterd.ai/blog/building-a-hipaa-compliant-medical-chatbot/)
- [Building a Privacy-Aware RAG System](https://philterd.ai/blog/building-a-privacy-aware-rag-system/)
- [Philter AI Proxy &mdash; drop-in LLM PII guardrails](https://philterd.ai/philter-ai-proxy/)
- [HHS Guidance on De-identification](https://www.hhs.gov/hipaa/for-professionals/privacy/special-topics/de-identification/index.html)
