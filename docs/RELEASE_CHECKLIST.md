# Release Checklist

Before publishing a release:

- [ ] `./scripts/validate.sh` passes locally.
- [ ] `claude plugin validate .` passes with the current Claude Code CLI.
- [ ] `claude plugin validate .claude-plugin/plugin.json` passes with the current Claude Code CLI.
- [ ] `CHANGELOG.md` has an entry for the release.
- [ ] `.claude-plugin/plugin.json` version is bumped.
- [ ] `.claude-plugin/marketplace.json` version and plugin entry version are bumped.
- [ ] The README install command matches the intended GitHub repo.
- [ ] No local paths, private notes, generated bundles, or test artifacts are tracked.
- [ ] A real local project has been appified and opened from `~/Desktop/MyApps/`.

For the first public GitHub setup:

- [ ] Repo description: `Turn local web projects into macOS Dock-launchable .app bundles with Claude Code.`
- [ ] Topics: `claude-code`, `claude-plugin`, `claude-skills`, `macos`, `dock`, `webkit`, `developer-tools`, `local-dev`.
- [ ] Issues enabled.
- [ ] Wiki disabled unless intentionally used.
- [ ] Social preview added if desired.
