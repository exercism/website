# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This file provides specific guidance for AI agents working on the Exercism website codebase. (`CLAUDE.md` is a symlink to this `AGENTS.md`.)

When you learn something new about working in this repo, record it here if it is safe to publish, or in `CLAUDE.local.md` (private and never committed) if it isn't. Never save these learnings to Claude's memory folder, because memories don't load reliably for every session and subagent.

## Big Picture

Exercism Website is a Ruby on Rails app (Ruby 3.4.4) with a React/TypeScript frontend. The two halves meet through server-rendered HAML views that mount React components and pass props as JSON:

- **Backend**: Rails controllers stay thin and delegate business logic to Mandate **commands** in `app/commands/`. Data leaving the app is shaped by **serializers** (`docs/context/serializers.md`) and **assemblers** (`docs/context/assemblers.md`) so API and SSR responses stay consistent.
- **View layer**: HAML templates in `app/views/` render **ViewComponents** (server-side, encapsulated logic, see `docs/context/view-components.md`) and mount **React components** (`app/javascript/components/`, `docs/context/react-components.md`).
- **Frontend**: React/TypeScript in `app/javascript/`, styled with PostCSS + Tailwind (`app/css/`, `tailwind.config.js`), built with esbuild (`app/javascript/esbuild.js`).
- **Routing**: three surfaces: standard user-facing routes, `/api` (Bearer-auth public/CLI/frontend endpoints, `config/routes/api.rb`), and `/spi` (internal AWS Lambda callbacks, no app-level auth, `config/routes/spi.rb`).

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

**Running a single test (fast feedback loop, preferred over the full suite while iterating):**

```bash
bin/rails test test/commands/user/update_test.rb         # one file
bin/rails test test/commands/user/update_test.rb:42      # one test by line number
yarn test path/to/Component.test.tsx                     # one JS test file (jest)
yarn test -t "renders the label"                         # JS tests matching a name
```

You do NOT need to run lint or rubocop on files before committing. These will AUTOMATICALLY happen via a git hook. Running before this just wastes time.

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
- Every command is a Mandate object: it does `include Mandate` and defines `call`. This applies to query logic that only loads data too. Never put a plain Ruby class with class methods under `app/commands/` and treat it as a command.
- Name each command with a leading verb for its operation (`Determine`, `Retrieve`, `Calculate`, `Update`, `Sync`), for example `User::InsidersStatus::DetermineEligibilityStatus` or `User::SetDiscordRoles`.
- Give each command one distinct operation. If a controller needs two things, it calls two commands and composes the results itself. Don't bundle unrelated queries into one command returning a hash.

**Testing Patterns:**

- Use FactoryBot: `create :user` for persisted, `build :user` for unsaved
- Minitest framework with helper methods in `test/test_helper.rb`
- System tests use Capybara for browser automation
- See `docs/context/testing/` for detailed patterns
- Never stub `Exercism.config` or `Exercism.s3_client`. Tests use the real config (from the exercism-config gem's `settings/ci.yml` and `local.yml`) and real LocalStack resources, so put real objects with `Exercism.s3_client.put_object` and read them back. A stub would hide a missing setting or bucket that would then break in production. If a setting is missing, add it to exercism/config (`../config/settings/*.yml`) and bump the gem. Some existing tests stub the config. Replace those stubs when you touch them, and don't copy them.

**Migrations:**

- Start `change` (or `up` and `down`) with `return if Rails.env.production?`. Production schema changes are applied out of band, so the migration runner must not apply them there.
- Name each migration file with a real full timestamp taken from `date +%Y%m%d%H%M%S`. Never pad the time with zeros (`20260812000000_...`). A zero-padded version looks hand-written, and it will collide with any other hand-written migration from the same day.
- If you change a migration's timestamp after running it locally, update its row in `schema_migrations` and the `version:` line in `db/schema.rb` to match.

**API Architecture:**

- `/api` routes for authenticated public endpoints (CLI, frontend)
- `/spi` routes for internal AWS Lambda services
- Always use Bearer token authentication for API
- Delegate business logic to commands, keep controllers thin

**Track maintenance status:**

- A track's maintained or unmaintained status lives in the GitHub repo topics on `exercism/<slug>`. Neither the website database nor team membership holds it. The category topics are `wip-track`, `unmaintained`, `maintained`, `maintained-autonomous` and `maintained-solitary`. `community-contributions-paused` is a separate topic with its own throttle.
- The website only reads these topics, in `Track::RetrieveCategories` (GraphQL, cached for a day). `Track#active` is a separate launch flag synced from the track's `config.json`, and has nothing to do with maintenance.
- The "This repo does not currently have dedicated maintainers" and "This is an unmaintained repository" PR comments come from `exercism/github-actions/.github/workflows/ping-cross-track-maintainers-team.yml`, which each track repo calls. That workflow reads only the repo topics and the live `cross-track-maintainers` team membership. Nothing in the website posts these comments.
- Membership of the GitHub `exercism/track-maintainers/<slug>` team defines who maintains a track. The website keeps a copy in `Github::TeamMember`, updated by webhooks (`Github::TeamMember::Create` and `Destroy`) with `SyncTeamMembersJob` as a backfill.
- Nothing keeps the topic in step with team membership, so a track gaining or losing its maintainers won't change its topic. (An automatic sync was proposed in #9289, which was closed unmerged.) To fix a repo by hand, run `gh api repos/exercism/<slug>/topics -X PUT -f names[]=exercism-track -f names[]=maintained`. This needs org owner or repo admin rights, and it replaces every topic on the repo, so include any other topics the repo should keep.

**Internationalization (i18n), active work:**

Hardcoded UI strings are being extracted into i18n. Two parallel systems:

- **Rails/HAML**: keys live in `config/locales/` (organized by area, e.g. `pages/`, `views/`). Reference with the standard `t('...')` / `I18n.t`.
- **React/TypeScript**: keys live in `app/javascript/i18n/en/`, one file **per component**, named after the component's path (e.g. `components-common-Loading.tsx.ts`). Each file `export default`s a nested object; the top comment records the namespace. In components, use `useAppTranslation('<namespace>')` from `@/i18n/useAppTranslation` and call `t('key.path')`. `app/javascript/i18n/generateIndexFile.ts` regenerates the aggregated `app/javascript/i18n/en/index.ts` from the per-component files.
- Some areas are intentionally **excluded** from extraction (bootcamp, admin, hiring, campaigns, dead mailers). Confirm scope before extracting strings in an unfamiliar area.
- **Translations** live in `exercism/i18n`, read by `lib/translation_repo.rb` from a plain checkout at `<efs_repositories_mount_point>/i18n` (`/opt/exercism/efs/repos/i18n` locally). To see a locale other than English, clone it there: `git clone --depth 1 --single-branch https://github.com/exercism/i18n.git /opt/exercism/efs/repos/i18n`, or run `bin/rails runner 'TranslationRepo::Sync.()'`, which clones and pulls the served locales the way production does. Without it every locale falls back to English.
- **Deploying a new locale takes two changes, in this order.** (1) `exercism/i18n`: the locale is in `targets` and, once complete, `productionTargets` in `locales.json`, so the checker and completeness gate hold it. (2) This repo: add it to `served` in `config/i18n.json` and a name to `Locale::Name::NAMES`.
- `config/i18n.json` is the one list of the locales the site serves, along with the public paths a first-time visitor may be moved between and the region/script variants of the multi-variant languages. Rails and the Cloudflare Worker in `cloudflare/locale-redirect/` both read it, and the Worker deploys in the same GitHub Actions run as the site. The Worker's Cloudflare routes live in `exercism/terraform` (`terraform/cloudflare/workers.tf`).

## Git Usage

- **Do not use `git -C <path>`**. Instead, `cd` to the correct directory before running git commands. This avoids issues with worktrees and ensures hooks run in the right context.
- **Never stage with `git add -A` or `git add .`**. Name each file you edited (`git add app/views/foo.haml test/controllers/foo_test.rb`), then check `git diff --cached --stat` before committing, or `git show --stat HEAD` after, and confirm every listed file is one you meant to change. Test runs and asset builds in this repo generate stray files (such as a `bun.lock`), and wide staging would sweep them into the commit.
- **Revise an open PR on its own branch**. When asked to change work in an open, unmerged PR, commit to that PR's branch. A new branch would split one change set across several PRs. Create a new branch only for independent work, or for follow-ups after the PR has merged.

## Sentry

- To resolve a Sentry issue, close its linked GitHub issue in exercism/website with `gh issue close`. Sentry's GitHub integration will then resolve it. Find the GitHub issue by its matching title or the link shown on the Sentry issue.
- Use the Sentry API only to ignore issues, never to resolve them.
- If a Sentry issue has no linked GitHub issue, ask before doing anything with it.

## Writing Style

- Never use em dashes in anything written for this repo, including copy, docs, code comments, commit messages and PR descriptions. They read as a sign of AI-generated text. Split the sentence in two, or use a comma, colon, brackets or a spaced hyphen. Verbatim third-party text (such as copy supplied by a sponsor) is the only exception. Flag it instead of editing it.

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

**Ask before starting services or system tests:**

- Never start Docker Desktop or any containers (LocalStack, OpenSearch, etc.) without explicit permission. If `bin/rails test` fails because they aren't running, commit and push so CI runs the tests, and say that they weren't run locally.
- Don't run system tests (`test/system`, or any Capybara browser test) without asking first. Validate changes with the relevant command, model and controller tests, and leave system tests to CI. The suite takes 15 to 20 minutes, and chromedriver hits a macOS Gatekeeper block ("chromedriver Not Opened") whenever `brew upgrade` installs a new version. To clear the block, run `xattr -d com.apple.quarantine` on the binary under `/opt/homebrew/Caskroom/chromedriver/<version>/chromedriver-mac-arm64/`.

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
