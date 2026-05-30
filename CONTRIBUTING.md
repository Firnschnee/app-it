# Contributing

This repo is intentionally narrow: make local web projects launchable from the macOS Dock.

Good contributions improve one of these:

- macOS launcher reliability.
- Project inspection accuracy.
- Reversibility and cleanup.
- Clearer docs for edge cases.
- Safer verification.

Please avoid broadening the plugin into general desktop-app distribution, signed customer releases, Electron migration, or Windows support. Those are different products.

Before opening a PR:

```bash
./scripts/validate.sh
```

If your change updates user-visible behavior, add a short note to `CHANGELOG.md`.
