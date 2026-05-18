# Community-contributed policies

This directory is for policies contributed by the community — anyone who is not the core Philterd team. The companion `philterd/` directory holds policies maintained by the Philterd team directly.

## Why the split?

- **Trust signal.** Visitors browsing the policy library see at a glance whether a policy comes from the Philterd team or from a community contributor. Both are valuable, but they carry different review depth and update cadence.
- **Maintenance separation.** Philterd commits to keeping its own policies current with the latest Philter releases and regulatory updates. Community-contributed policies are owned by their authors — they may not be actively maintained.
- **Attribution.** Community contributors get visible credit on the policy's page on philterd.ai, and in the `creator` and `author` frontmatter fields.

## Contributing

See the top-level [CONTRIBUTING.md](../../CONTRIBUTING.md) for the full process. Quick version:

1. Pick a category subdirectory (or propose a new one in an issue first).
2. Add `<your-slug>.json` and `<your-slug>.md` per the schema.
3. Set the `creator` frontmatter field to your name or organization (not `"philterd"` — that's reserved for the core team's policies).
4. Open a PR. CI validates schema and metadata; reviewers check for compliance accuracy.

## Slug uniqueness

Policy slugs must be globally unique across both `philterd/` and `community/` directories. If your slug collides with an existing one, the reviewer will ask you to rename. This keeps URLs on philterd.ai stable and unambiguous.
