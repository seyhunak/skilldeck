---
name: dockerfile-hardening
description: Reviews and rewrites Dockerfiles for security and efficiency - multi-stage builds, pinned base images by digest, non-root users, minimal or distroless runtimes, secret-free layers, cache-friendly layer order, and .dockerignore. Use when creating a production Dockerfile, reviewing one in a pull request, or shrinking an image flagged by a scanner.
---

# Dockerfile Hardening

A default Dockerfile tends to ship a compiler, a shell, a package manager, the build cache, and sometimes a secret, all running as root. This skill applies a short list of high-value controls and verifies them, producing a smaller image with less attack surface and faster rebuilds.

## When to use

- Writing a production Dockerfile for a service or CLI.
- Reviewing a Dockerfile change, or remediating findings from Trivy, Grype, Docker Scout, Snyk, or hadolint.
- Image is large, slow to build, or rebuilds everything on every code change.

Not for: Kubernetes manifests, Terraform, and wider infrastructure review (`infrastructure-as-code-review-agent`) or pipeline failures (`cicd-troubleshooting-agent`).

## Inputs

- The current Dockerfile and `.dockerignore` (if any).
- Language/runtime and how the app is built and started (build command, artefact path, port, entrypoint).
- Constraints: required OS packages, need for a shell in production for debugging, target architectures (amd64/arm64), registry and scanner in use.

## Procedure

1. **Lint first.** Run `hadolint Dockerfile` and note rule ids (e.g. DL3007 for `latest` tag, DL3008 for unpinned apt packages, DL3002 for last user root). Use findings as a starting checklist, not the full review.

2. **Split build and runtime with multi-stage builds.** Build stage has compilers and dev dependencies; final stage copies only the artefact: `COPY --from=build /app/dist /app`. For Go/Rust static binaries the runtime can be `gcr.io/distroless/static` or `scratch`; for JVM, Node, or Python use distroless or slim variants of the runtime, matched to the build stage's libc (do not build against glibc and run on musl/Alpine without checking).

3. **Pin base images.** Use an explicit version tag plus digest: `FROM node:22.11-bookworm-slim@sha256:<digest>`. Tags move; digests do not. Pair with an automated updater (Renovate or Dependabot) so pinning does not mean never patching.

4. **Order layers for caching.** Copy dependency manifests and install dependencies before copying source: `COPY package.json package-lock.json ./` → `RUN npm ci --omit=dev` → `COPY . .`. Use BuildKit cache mounts for package caches (`RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt`). Combine `apt-get update && apt-get install -y --no-install-recommends ... && rm -rf /var/lib/apt/lists/*` in one `RUN`.

5. **Keep secrets out of layers.** Never `COPY .env`, `ARG TOKEN`, or `ENV PASSWORD=` — build args and env values persist in image history (`docker history --no-trunc` shows them). Use `RUN --mount=type=secret,id=npm_token ...` with `docker build --secret id=npm_token,src=...`. Deleting a secret in a later layer does not remove it from the earlier one.

6. **Write a strict `.dockerignore`.** Exclude `.git`, `node_modules`, build output, local env files, test fixtures with data, IDE folders, and the Dockerfile itself if not needed. This shrinks context, speeds builds, and prevents accidental secret copies via `COPY . .`.

7. **Run as non-root.** Create a user with a fixed UID (`RUN useradd --uid 10001 --no-create-home app`) or use the image's built-in non-root user (distroless `:nonroot`, Node `node`). Set `USER 10001` (numeric lets Kubernetes `runAsNonRoot` verify it). Ensure writable paths are owned by that user (`COPY --chown=10001:10001`). Listen on ports above 1024.

8. **Tighten runtime behaviour.** Use exec-form `ENTRYPOINT ["/app/server"]` so the process is PID 1 and receives SIGTERM; add `tini` or `--init` if the app spawns children. Add `HEALTHCHECK` only if the orchestrator uses it (Kubernetes ignores it in favour of probes). Prefer `COPY` over `ADD` (ADD fetches URLs and auto-extracts archives). Set OCI labels (`org.opencontainers.image.source`, `.revision`).

9. **Verify.** Build, then check: `docker image ls` size before/after; `docker history` shows no secrets; `docker run --rm --entrypoint id <img>` (where a shell or `id` exists) shows non-root, or inspect `Config.User`; scan with `trivy image <img>` and compare critical/high counts; run the app with `--read-only --cap-drop=ALL` to confirm it does not need more.

## Expected output

```markdown
### Findings
| # | Severity | Issue | Line | Fix |
### Hardened Dockerfile
    <full Dockerfile>
### .dockerignore
    <entries>
### Verification
| Check | Before | After |
| Image size | | |
| Runs as | root | 10001 |
| Critical/High CVEs (scanner, date) | | |
### Trade-offs
<e.g. no shell in distroless: debug with ephemeral containers>
```

## Constraints and limitations

- Do not claim CVE counts or sizes you did not measure; give expected direction and let the user run the scan.
- Distroless and scratch images remove shells and package managers; document how to debug (`kubectl debug`, a separate `-debug` tag).
- Alpine's musl can break prebuilt native modules and change DNS behaviour; recommend it only after testing.
- Hardening the image does not replace runtime controls (seccomp, read-only rootfs, network policy).

## Examples

**Before:** `FROM python:latest`, `COPY . .`, `RUN pip install -r requirements.txt`, runs as root, 1.1 GB per the user's `docker image ls`.
**After:** builder stage `python:3.12-slim-bookworm@sha256:...` creating a virtualenv with a pip cache mount; runtime stage from the same slim base copying only `/opt/venv` and `src/`; `USER 10001`; exec-form `CMD ["python", "-m", "app"]`; `.dockerignore` excluding `.git`, `.venv`, `tests/`, `.env*`. Size and scanner counts are recorded from the user's rebuild rather than predicted.
