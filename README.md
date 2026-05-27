# Philterd PII Redaction Policies

A curated, community-contributed library of [Philter](https://philterd.ai/philter/) and [Phileas](https://philterd.ai/phileas/) redaction policies — covering common compliance frameworks (HIPAA, PCI DSS, GLBA, FERPA, FRCP 5.2), vertical use cases (healthcare clinical notes, contact-center transcripts, AI training data), and general-purpose starting points.

Each policy is a working JSON file you can drop into a Philter or Phileas deployment. Each policy is paired with a sidecar `.md` file that documents what it does, when to use it, what's tunable, and a sample input/output pair.

## Browse the library

A searchable, browsable version of this library is rendered on **[philterd.ai/policies/](https://philterd.ai/policies/)**.

## Repo layout

```
policies/
├── philterd/               Policies maintained by the Philterd team
│   ├── healthcare/         HIPAA Safe Harbor, clinical notes, medical chatbot
│   ├── finance/            PCI DSS, GLBA NPPI
│   ├── legal/              Bankruptcy Rule 9037, e-discovery
│   ├── government/         FOIA preparation, FedRAMP-adjacent
│   ├── education/          FERPA, student records
│   ├── ai-training/        LLM fine-tuning data prep, RAG ingestion
│   ├── contact-center/     Call-recording transcripts, PCI scope reduction
│   └── general/            General-purpose starting points
└── community/              Policies contributed by the community
    └── <category>/         Same per-category layout
```

**Why the philterd/ vs community/ split:** policies under `philterd/` are maintained by the core team and kept current with Philter releases. Policies under `community/` are owned by their contributors. Both are valuable; the split makes it obvious which is which.

For each policy, two files live in the same directory:

| File | Purpose |
|---|---|
| `<slug>.json` | The policy itself — load this into Philter or Phileas |
| `<slug>.md` | Metadata + description, rendered on philterd.ai/policies/ |

## Using a policy

### With Philter (HTTP API)

```bash
# Download the policy
curl -O https://raw.githubusercontent.com/philterd/pii-redaction-policies/main/policies/philterd/healthcare/hipaa-safe-harbor.json

# Upload to your Philter instance
curl -X POST http://localhost:8080/api/policies \
     -H "Content-Type: application/json" \
     --data @hipaa-safe-harbor.json

# Redact text using the policy
curl http://localhost:8080/api/filter?p=hipaa-safe-harbor \
     --data "Patient John Smith was discharged on 2025-03-14." \
     -H "Content-Type: text/plain"
```

### With Phileas (embedded)

See language-specific usage in the [Phileas docs](https://philterd.github.io/phileas/) or [philterd.ai/phileas/](https://philterd.ai/phileas/).

## Contributing

Pull requests welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the file layout, metadata schema, and the golden-file test pattern every policy needs to pass.

## Versioning

Each policy carries its own semver in its `.md` frontmatter. The repo itself is git-versioned, so old versions of any policy are recoverable from history. Breaking changes to a policy should bump the major version and ideally be documented in the policy's markdown body.

## License

All policies are released under the [Apache License 2.0](LICENSE), matching the rest of the [Philterd toolkit](https://github.com/philterd). Contributions are accepted under the same terms.

## Policy schema

All policies are validated against the [redaction policy JSON schema](https://github.com/philterd/phileas/blob/main/policy-schema/redaction-policy-schema.json) maintained in the Phileas repository.

## Compatibility

Policies in this repo target Philter `>=3.0.0` unless a specific compatibility range is noted in the policy's `.md` frontmatter. Older versions may need minor adjustments to the JSON schema.

## Disclaimer

These policies are starting points, not legal advice. Compliance regimes (HIPAA, GDPR, PCI DSS, etc.) require deployment-specific evaluation. Always validate the policy against your own representative data before relying on it in production. The policy's `useCase` and `complianceNotes` describe the *intent*, not a certification.
