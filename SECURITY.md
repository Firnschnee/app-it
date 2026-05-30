# Security

`app-it` is a local developer tool. It should not collect telemetry, upload project files, or send source code to any service.

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

## Reporting Issues

Open a GitHub issue with a minimal reproduction. Do not include secrets, private `.env` values, customer data, or proprietary source code.
