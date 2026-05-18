# Contributing a policy

Pull requests welcome. The process is designed to be lightweight while still keeping the library trustworthy.

## What makes a good policy

- **Specific.** Targets a well-defined use case (one compliance framework, one document type, one vertical workflow). Catch-all "redact everything" policies are less useful than focused ones.
- **Documented.** The sidecar `.md` explains what it does, when to use it, what to tune, and any compliance caveats.
- **Tested.** Comes with an `examples/inputs/<slug>.txt` and an `examples/outputs/<slug>.redacted.txt` pair so reviewers (and CI) can see the policy's effect on a representative document.
- **Licensed.** You're submitting under [Apache 2.0](LICENSE) — same as the rest of the repo.

## File layout

For a policy named `your-policy-slug` in the `healthcare` category:

```
policies/healthcare/your-policy-slug.json     # the policy itself
policies/healthcare/your-policy-slug.md       # metadata + description
examples/inputs/your-policy-slug.txt          # representative input (optional but recommended)
examples/outputs/your-policy-slug.redacted.txt  # what the policy produces on the above input
```

Slugs are kebab-case and match the URL the policy will get on philterd.ai (`/policies/healthcare/your-policy-slug/`).

## Sidecar `.md` schema

Every policy `.json` must have a sibling `.md` with this frontmatter:

```yaml
---
title: "Human-Readable Title"            # required
slug: "your-policy-slug"                 # required, must match filename
category: "healthcare"                   # required, must match directory
tags: ["HIPAA", "Safe Harbor"]           # required, at least one
author: "Your name or org"               # required
version: "1.0.0"                         # required, semver
updated: "2026-05-18"                    # required, YYYY-MM-DD
philterCompatibility: ">=3.0.0"          # required, semver range
useCase: "One-sentence summary."         # required, 80-160 chars
entities: ["NAME", "DATE", "SSN"]        # required, types the policy acts on
exampleInput: "Patient John Smith..."    # optional, shown on the policy page
exampleOutput: "Patient {{NAME}}..."     # optional, shown alongside input
---

## What this policy does

Full markdown body — explains the policy, its compliance basis if any, what's tunable, citations.

## When to customize

- Concrete examples of fields that vary by deployment

## Compliance notes

If the policy targets a specific regulation, cite the relevant section and link to authoritative sources.
```

## Validating locally

Before opening a PR, run the local validator:

```bash
bash tests/validate.sh
```

This checks:
- Every `.json` parses as valid JSON
- Every `.json` has a sibling `.md`
- Every `.md` has the required frontmatter fields
- Every policy passes the JSON schema in `schema/policy.schema.json`
- Golden-file tests: if `examples/inputs/<slug>.txt` exists, the policy must produce `examples/outputs/<slug>.redacted.txt` (skipped if no input file is provided)

CI runs the same checks on every PR.

## Naming conventions

- **Slugs**: kebab-case, descriptive. `hipaa-safe-harbor` not `hsh` or `hipaa_safe_harbor`.
- **Categories**: existing directories preferred. Open an issue first if you think a new category is warranted.
- **Tags**: title-case, specific. Prefer existing tags over inventing new ones; check existing policies first.

## Versioning your policy

Each policy carries its own semver in the `.md` frontmatter:

- **Major** — breaking change (a previously-redacted entity is now passed through, or vice versa)
- **Minor** — additive change (new entity type added, new condition supported)
- **Patch** — bugfix or wording (typo in a regex, clarified description)

Bump the version and update the `updated:` date on every change.

## Compliance disclaimer

Policies in this repo are starting points, not legal advice or compliance certification. If you're submitting a policy that targets a specific regulatory framework (HIPAA, GDPR, PCI DSS, etc.), include citations and be explicit in the markdown about what the policy does and doesn't cover. Reviewers may ask for tightening of compliance claims.
