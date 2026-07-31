# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This file provides specific guidance for AI agents working on the Exercism website codebase. (`CLAUDE.md` is a symlink to this `AGENTS.md`.)

## Big Picture

Exercism Website is a Ruby on Rails app (Ruby 3.4.4) with a React/TypeScript frontend. The two halves meet through server-rendered HAML views that mount React components and pass props as JSON:

- **Backend**: Rails controllers stay thin and delegate business logic to Mandate **commands** in `app/commands/`. Data leaving the app is shaped by **serializers** (`docs/context/serializers.md`) and **assemblers** (`docs/context/assemblers.md`) so API and SSR responses stay consistent.
- **View layer**: HAML templates in `app/views/` render **ViewComponents** (server-side, encapsulated logic — `docs/context/view-components.md`) and mount **React components** (`app/javascript/components/`, `docs/context/react-components.md`).
- **Frontend**: React/TypeScript in `app/javascript/`, styled with PostCSS + Tailwind (`app/css/`, `tailwind.config.js`), built with esbuild (`app/javascript/esbuild.js`).
- **Routing**: three surfaces — standard user-facing routes, `/api` (Bearer-auth public/CLI/frontend endpoints, `config/routes/api.rb`), and `/spi` (internal AWS Lambda callbacks, no app-level auth, `config/routes/spi.rb`).

### Exploring the codebase with graphify (optional)

For a queryable knowledge graph of `app/` (call graphs, community structure, cross-module bridges), run `/graphify app` locally (or `graphify` CLI, installed via `uv tool install graphifyy`). It builds a code-only graph via deterministic AST — no LLM cost, ~30s — and writes `graphify-out/` (git-ignored). Regenerate it yourself rather than relying on a committed copy; the graph is a point-in-time snapshot and goes stale as code changes. Use `graphify query "<question>"` against the built graph to answer architecture questions.

## Complete Documentation

For comprehensive documentation about the application architecture, setup, and patterns, see [`docs/context/overview.md`](docs/context/overview.md). The `docs/context/` directory contains detailed documentation on all aspects of the application:

- `overview.md` - Complete application documentation and setup guide
- `running-the-app.md` - Environment setup and development server
- `commands.md` - Mandate command pattern documentation
- `API.md` - API architecture and authentication patterns
- `SPI.md` - Internal service endpoints
- `testing/` - Comprehensive testing patterns and examples
  - `testing/screenshots.md` - Screenshot generation and visual testing with AI analysis
- And more component-specific documentation

**Always reference the relevant docs in `docs/context/` when working on specific features.**

## Essential Commands

**Validation commands:**

- **Tests**: `bin/rails test` (Rails TestUnit with FactoryBot)
- **Linting**: `bin/rubocop -a` (auto-fixes issues)
- **Security**: `bin/brakeman`

**IMPORTANT:** Linting and security checks are run automatically by the git pre-commit hook. For basic changes, you don't need to run these yourself - just let the git hook handle it when you commit. For more complex changes, run tests manually during development, but leave rubocop and brakeman to the git hook. If making front-end changes, run `yarn test` before committing.

**Development server:**

```bash
./bin/dev  # Preferred - handles all setup automatically
```

**Manual testing:**

```bash
bundle exec rails test              # Ruby tests (10-15 min)
bundle exec rails test test/system  # System tests (15-20 min)
yarn test                          # JavaScript tests (2-3 min)
```

**Running a single test (fast feedback loop — prefer this over the full suite while iterating):**

```bash
bin/rails test test/commands/user/update_test.rb         # one file
bin/rails test test/commands/user/update_test.rb:42      # one test by line number
yarn test path/to/Component.test.tsx                     # one JS test file (jest)
yarn test -t "renders the label"                         # JS tests matching a name
```

**Lint only staged changes** (what the pre-commit hook runs — faster than a full pass):

```bash
bin/rubocop-quick     # rubocop --except Metrics on staged .rb, then re-stages
bin/eslint-quick      # eslint on staged .js/.ts/.jsx/.tsx, then re-stages
bin/haml-lint-quick   # haml-lint on staged .haml
```

**Asset builds:**

```bash
yarn build:css && yarn build       # Build all assets
rm -rf .built-assets/              # Clear asset cache if needed
```

## Code Patterns & Conventions

**Command Pattern (Critical):**

- Business logic goes in `/app/commands/` using Mandate gem
- Controllers delegate to commands: `cmd = User::Update.(user, params)`
- Use `.on_success` and `.on_failure` callbacks in API controllers
- Commands should have short `call` methods that delegate to private methods

**Testing Patterns:**

- Use FactoryBot: `create :user` for persisted, `build :user` for unsaved
- Minitest framework with helper methods in `test/test_helper.rb`
- System tests use Capybara for browser automation
- See `docs/context/testing/` for detailed patterns

**API Architecture:**

- `/api` routes for authenticated public endpoints (CLI, frontend)
- `/spi` routes for internal AWS Lambda services
- Always use Bearer token authentication for API
- Delegate business logic to commands, keep controllers thin

**Internationalization (i18n) — active work:**

Hardcoded UI strings are being extracted into i18n. Two parallel systems:

- **Rails/HAML**: keys live in `config/locales/` (organized by area, e.g. `pages/`, `views/`). Reference with the standard `t('...')` / `I18n.t`.
- **React/TypeScript**: keys live in `app/javascript/i18n/en/`, one file **per component**, named after the component's path (e.g. `components-common-Loading.tsx.ts`). Each file `export default`s a nested object; the top comment records the namespace. In components, use `useAppTranslation('<namespace>')` from `@/i18n/useAppTranslation` and call `t('key.path')`. `app/javascript/i18n/generateIndexFile.ts` regenerates the aggregated `app/javascript/i18n/en/index.ts` from the per-component files.
- Some areas are intentionally **excluded** from extraction (bootcamp, courses, admin, hiring, campaigns, dead mailers). Confirm scope before extracting strings in an unfamiliar area.

## Git Usage

- **Do not use `git -C <path>`**. Instead, `cd` to the correct directory before running git commands. This avoids issues with worktrees and ensures hooks run in the right context.

## Critical Warnings

**Never cancel long-running operations:**

- `bundle install`: 15-20 minutes (native extensions)
- Full test suite: 10-15 minutes
- System tests: 15-20 minutes

**Version requirements (exact):**

- Ruby 3.4.4 (will fail with other versions)
- Node.js 20+
- MySQL 5.7

**Required services:**

- Docker (LocalStack, OpenSearch)
- Redis, MySQL
- Run `./bin/dev` to start everything

## File Organization

**Key directories:**

- `app/commands/` - Business logic (Mandate pattern)
- `app/controllers/api/` - Public API endpoints
- `app/controllers/spi/` - Internal service endpoints
- `test/` - All test files
- `docs/context/` - Detailed component documentation

**When editing:**

1. Read relevant `docs/context/*.md` files first
2. Follow existing patterns in similar files
3. Use commands for business logic, not controllers
4. Add appropriate tests (see testing docs)
5. Run pre-commit validation commands

## Reference Documentation

- `docs/context/overview.md` - Complete codebase documentation and setup guide
- `docs/context/running-the-app.md` - Environment setup and development server
- `docs/context/commands.md` - Command pattern details
- `docs/context/testing/` - Testing patterns and examples
