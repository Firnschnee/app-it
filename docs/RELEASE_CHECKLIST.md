# Release Checklist

Before publishing a release:

- [ ] `./scripts/validate.sh` passes locally.
- [ ] `claude plugin validate .` passes with the current Claude Code CLI.
- [ ] `claude plugin validate plugins/app-it/.claude-plugin/plugin.json` passes with the current Claude Code CLI.
- [ ] Codex install smoke passes in a temp home (both installable plugins):
  `tmp_home="$(mktemp -d)" && HOME="$tmp_home" codex plugin marketplace add . && HOME="$tmp_home" codex plugin add app-it@app-it && HOME="$tmp_home" codex plugin add app-it-static@app-it`.
- [ ] `CHANGELOG.md` has an entry for the release.
- [ ] `plugins/app-it/.claude-plugin/plugin.json` version is bumped.
- [ ] `plugins/app-it/.codex-plugin/plugin.json` version is bumped.
- [ ] `plugins/app-it-static/.claude-plugin/plugin.json` + `.codex-plugin/plugin.json` versions are bumped together (when the static plugin changed).
- [ ] `.claude-plugin/marketplace.json` version and **each** plugin entry version are bumped (app-it, app-it-static, app-it-windows).
- [ ] `.agents/plugins/marketplace.json` lists all three plugins with correct paths.
- [ ] Shared templates are byte-identical across `app-it` and `app-it-static` (validate.sh's drift guard passes).
- [ ] The README install command matches the intended GitHub repo.
- [ ] No local paths, private notes, generated bundles, or test artifacts are tracked.
- [ ] A real local project has been appified and opened from `~/Applications/App It/`.

For the first public GitHub setup:

- [ ] Repo description: `Turn local web projects into macOS Dock-launchable .app bundles with Claude Code and Codex.`
- [ ] Topics: `claude-code`, `claude-plugin`, `claude-skills`, `macos`, `dock`, `webkit`, `developer-tools`, `local-dev`.
- [ ] Issues enabled.
- [ ] Wiki disabled unless intentionally used.
- [ ] Social preview added if desired.
