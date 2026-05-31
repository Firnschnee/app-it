# 0006 — `app-it-static`: a companion that serves the build, not a dev server

**Status:** Accepted

## Context

`app-it` makes a local project clickable by booting its **dev server** behind the
native window. That's right for a *live, in-progress* project — but a *finished*
app doesn't need a dev server, and a dev server is expensive: Vite/Next dev keeps
a bundler, file-watcher, and transpiler resident, typically 300–700 MB per app.
The r/ClaudeAI launch thread surfaced this directly (README → Community nudge):
finished apps shouldn't pay dev-server RAM, and Vercel+PWA — while lighter — isn't
always available (no finished output to deploy yet; corporate environments where
external hosting isn't approved).

## Decision

Ship a **separate macOS sibling plugin, `app-it-static`**, for finished or
buildable apps. It builds once and **serves the built output** — from a tiny
zero-dependency `static-server.py` (~15 MB) or directly via `file://` (~0 MB) —
and never runs `npm run dev`. It reuses `app-it`'s native Swift WebKit window,
icon pipeline, and one-folder Dock install verbatim; the five shared templates
are byte-identical and CI guards them against drift.

Two deliberate constraints keep it honest and small:

- **Snapshot, not live.** The launcher serves the build as of build time. Source
  changes don't appear until `desktop:rebuild`. This is the defining difference
  from `app-it` and is stated everywhere a user can see it, never hidden.
- **Server by default, `file://` only when proven safe.** `file://` is lightest
  but breaks for most framework builds (absolute asset paths, client-side
  routing, local `fetch`, service workers). The tiny static server is the safe
  default; `file://` is an opt-in optimization for confirmed-flat builds.

## Alternatives considered

- **Bolt static serving onto `app-it` as a flag.** Rejected: it would bloat the
  proven dev-server skill's decision tree with a different lifecycle (snapshot vs
  live, build-once vs boot-server) and blur its contract. A focused companion is
  cleaner — and is *simpler* than `app-it`, not more complex, because it drops the
  hardest parts (live dev-server lifecycle, multi-server cohabitation, the FSA
  polyfill, env-driven port carve-outs).
- **Make `app-it-static` a Vercel/PWA/deploy tool.** Rejected: out of scope and
  network-dependent. The whole point is a *local* answer to the RAM critique that
  also works where external hosting is blocked. No cloud, no telemetry.
- **Always use `file://` (zero server).** Rejected as the default: it 404s or
  blanks for absolute-path and client-routed builds, which is most of them. Kept
  as an opt-in for confirmed-safe builds.
- **A separate repository.** Rejected: `app-it-static` is a companion, not a
  standalone product. Same repo means shared CI, the drift-guarded Swift shell,
  one install story, and one Dock Stack for live + finished apps. (Mirrors the
  ADR 0002 reasoning for keeping siblings in one repo as separate plugins.)

## Consequences

- Finished apps cost ~15 MB (server) or ~0 MB (`file://`) instead of 300–700 MB.
- A new honest caveat to teach: the snapshot model and `desktop:rebuild`.
- A maintenance invariant: the five shared templates must stay byte-identical
  between `app-it` and `app-it-static`; `validate.sh` enforces it. Launcher fixes
  land in `app-it` first, then re-sync.
- `python3` joins `swiftc` as a documented requirement (both ship with the Xcode
  Command Line Tools; no new third-party dependency).
