# Repository survey checklist

Language-specific places to look when surveying a codebase. Use it alongside the operating procedure; skip rows that do not apply.

| Ecosystem | Manifest and lockfile | Entry points | Configuration | Tests |
|---|---|---|---|---|
| JavaScript / TypeScript | `package.json`, `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock` | `main`/`bin`/`exports` in package.json, `src/index.*`, `server.*`, Next.js `app/` and `pages/` | `.env.example`, `next.config.*`, `vite.config.*`, `tsconfig.json` | `*.test.*`, `*.spec.*`, `__tests__/`, `vitest.config.*`, `jest.config.*` |
| Python | `pyproject.toml`, `requirements*.txt`, `poetry.lock`, `uv.lock` | `__main__.py`, `[project.scripts]`, `manage.py`, `app.py`, `wsgi.py`, `asgi.py` | `settings.py`, `config/`, `.env.example` | `tests/`, `test_*.py`, `conftest.py`, `pytest.ini` |
| Go | `go.mod`, `go.sum` | `cmd/*/main.go`, `main.go` | `config/`, flags in `main.go` | `*_test.go` |
| Rust | `Cargo.toml`, `Cargo.lock` | `src/main.rs`, `src/bin/`, `[[bin]]` | `config/`, `build.rs` | `tests/`, `#[cfg(test)]` modules |
| Java / Kotlin | `pom.xml`, `build.gradle(.kts)` | classes with `main`, `@SpringBootApplication` | `application.yml`, `application.properties` | `src/test/` |
| Swift | `Package.swift`, `*.xcodeproj`, `project.yml` | `@main` types, `AppDelegate`, `SceneDelegate` | `Info.plist`, `*.xcconfig`, entitlements | `Tests/`, `*Tests.swift` |
| Ruby | `Gemfile`, `Gemfile.lock` | `config.ru`, `bin/`, Rails `config/routes.rb` | `config/` | `spec/`, `test/` |

## Cross-cutting

- **CI/CD:** `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/` — the most reliable description of the real build.
- **Infrastructure:** `Dockerfile`, `docker-compose.yml`, `terraform/`, `helm/`, `k8s/`, `serverless.yml`.
- **Data:** `migrations/`, `schema.prisma`, `db/schema.rb`, `alembic/`, `*.sql`.
- **Ownership:** `CODEOWNERS`, `MAINTAINERS`, commit history.
- **Generated code:** files with "DO NOT EDIT" headers, `*.pb.go`, `*_generated.*`, `openapi/` outputs — survey the generator input instead.

## Questions to answer before writing the brief

1. Can I state in one sentence what this system does?
2. Can I name the command that runs the tests and where I found it?
3. Can I trace one user-facing operation from entry point to storage?
4. Do I know where the schema of record lives?
5. Have I listed which documentation claims I could not confirm?
