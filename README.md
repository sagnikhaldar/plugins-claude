# sagnikhaldar/plugins-claude

A Claude Code plugin marketplace.

## Available plugins

- **[gin-recon](https://github.com/sagnikhaldar/gin-recon)** — deterministic
  static-analysis inventory and audit for Gin route surfaces. Enumerates
  routes and middleware chains, classifies authentication as
  proven/public/unknown, and generates OpenAPI 3.1, SARIF, and HTML
  documentation. No AI, no target execution.

## Install

```text
/plugin marketplace add sagnikhaldar/plugins-claude
/plugin install gin-recon@sagnikhaldar
```

Once installed, prompts like *"audit my Gin routes"* or *"document my Gin
API"* will route through the plugin automatically.

## Catalog version sync

Each plugin's version lives in its own repo (`.claude-plugin/plugin.json`) —
that's the source of truth. The [`Sync plugin versions`](.github/workflows/sync-versions.yml)
workflow mirrors those into `marketplace.json` daily (and on manual dispatch),
opening a PR when anything changed, so the catalog never drifts from a
release.

This needs **Settings → Actions → General → Workflow permissions → "Allow
GitHub Actions to create and approve pull requests"** enabled, so the
workflow's token can open the sync PR.
