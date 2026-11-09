# Upgrade Checklist: Where Breakage Hides

Use this list during inventory (step 3) and constraint resolution (step 5). Ecosystem notes describe common patterns; verify against the specific release notes.

## All ecosystems

- Minimum runtime or compiler version raised by the new major.
- Default values that changed (timeouts, strictness flags, serialisation formats, time zones).
- Removed deprecated APIs: grep build logs and test output for deprecation warnings on the current version.
- Plugins, adapters, and type packages that must move in lockstep.
- Configuration files read by the dependency (renamed keys are silently ignored by some tools).
- Behaviour that tests do not cover: logging format, error messages parsed elsewhere, ordering of results.

## JavaScript / TypeScript

- Peer dependency ranges in plugins; `overrides` (npm), `resolutions` (Yarn), or `pnpm.overrides` used as temporary bridges.
- ESM versus CommonJS changes: default export shape, `require` of an ESM-only package.
- Bundler and test-runner config coupled to framework majors.
- Separately versioned type definitions (`@types/*`).

## Python

- Upper bounds in other packages' metadata blocking resolution.
- Removed or renamed modules; import-time side effects.
- Changes in supported Python versions and in C-extension wheels for your platforms.

## JVM

- Package namespace moves (for example `javax.*` to `jakarta.*` in Jakarta EE 9+).
- Bytecode target version and build plugin versions.
- Dependency convergence across BOMs.

## Go

- Major versions in import paths (`/v2`, `/v3`); both can coexist, enabling module-by-module migration.

## Ruby

- Gem version constraints in the Gemfile.lock across groups; Rails framework defaults toggled per version.

## Runtimes and toolchains

- Container base images and CI images pin runtimes separately from code.
- Native modules must be rebuilt.
- Memory and GC behaviour can change; watch memory and latency during canary.

## Before the bump PR merges

- Deprecation warnings at zero on the old version where feasible.
- Codemod commits separated from manual edits.
- Overrides and shims recorded with a removal ticket.
- Rollback path tested: reverting the bump commit restores a working build.
