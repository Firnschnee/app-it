# Security

`app-it` is a personal, open-source project, maintained by one developer in their
spare time and offered under the MIT [LICENSE](LICENSE) with no warranty. It is an
independent community tool, **not affiliated with or endorsed by Anthropic or OpenAI.**

It is a local developer tool. It should not collect telemetry, upload project
files, or send source code to any service.

## What It Can Do

- Read a local project to choose a launcher strategy.
- Add scripts, docs, icons, and generated `.app` bundles to that project.
- Start and stop local dev-server processes during verification.

## What It Should Not Do

- Handle secrets.
- Modify production infrastructure.
- Install global dependencies without saying so.
- Send project data over the network.
- Claim that ad-hoc signed local `.app` bundles are notarized or ready for distribution.

## Reporting a Vulnerability

For a normal bug, open a public [GitHub issue](https://github.com/Christian-Katzmann/app-it/issues)
with a minimal reproduction.

For something security-sensitive that shouldn't be public yet, please report it
privately instead of opening an issue: use GitHub's
[private vulnerability reporting](https://github.com/Christian-Katzmann/app-it/security/advisories/new)
on this repository. As a one-person project there is no formal SLA, but reports
are read and triaged in good faith, and fixes are prioritized by severity.

Either way, do not include secrets, private `.env` values, customer data, or
proprietary source code in your report.
