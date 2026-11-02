# Community policy starter

Use this starter for the four files that make up a community policy
contribution. It uses the fictional identifier `DEMO-1234`. This is not a real
personal identifier or a compliance policy. Replace it with safe, invented
values for your own policy before submitting.

Copy and rename the policy JSON and sidecar to
`policies/community/<category>/<slug>.json` and
`policies/community/<category>/<slug>.md`. Copy the example input and output to
`examples/inputs/<slug>.txt` and
`examples/outputs/<slug>.redacted.txt`.

Before opening a pull request:

- Replace the sample pattern, classification, redaction format, title, slug,
  category, tags, author, creator, use case, and examples.
- Keep the sidecar `slug` identical to both filenames and `category` identical
  to the policy's directory.
- Set `creator` to your name or organization, not `philterd`.
- Use only invented example data, and make the output match what the policy
  actually produces.
- Follow the full [contribution guide](CONTRIBUTING.md), including its
  validation and policy-versioning instructions.

## `policy.json`

```json
{
  "config": {
    "splitting": {
      "enabled": false,
      "threshold": 4000
    }
  },
  "ignored": [],
  "identifiers": {
    "identifiers": [
      {
        "classification": "demo-id",
        "pattern": "\\bDEMO-[0-9]{4}\\b",
        "caseSensitive": false,
        "identifierFilterStrategies": [
          {
            "strategy": "REDACT",
            "redactionFormat": "[REDACTED-DEMO-ID]"
          }
        ]
      }
    ]
  }
}
```

## `policy.md`

```markdown
---
title: "Example identifier redaction"
slug: "example-identifier"
category: "general"
tags: ["Example"]
author: "Your name or organization"
creator: "your-name-or-organization"
version: "1.0.0"
updated: "2026-11-01"
philterCompatibility: ">=4.0.0"
useCase: >-
  Redacts a fictional reference code from support records before sharing
  outside the service team.
entities: ["DEMO_ID"]
exampleInput: "Case 42: review DEMO-1234."
exampleOutput: "Case 42: review [REDACTED-DEMO-ID]."
---

## What this policy does

Describe the information this policy detects, the context where it is useful,
and how the configured filters handle it.

## When to customize

Explain which settings a user may need to tune and provide concrete examples.

## Compliance notes

Cite authoritative sources for any regulatory claims. State limitations
clearly; a policy is not legal advice or compliance certification.
```

## `examples/inputs/<slug>.txt`

```text
Case 42: review DEMO-1234.
```

## `examples/outputs/<slug>.redacted.txt`

```text
Case 42: review [REDACTED-DEMO-ID].
```
