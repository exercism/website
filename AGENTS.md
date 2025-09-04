# AI Agent Instructions for Exercism Website

This file provides specific guidance for AI agents working on the Exercism website codebase.

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

**Pre-commit validation (ALWAYS run before committing):**

```bash
bundle exec rubocop --except Metrics
yarn test
bundle exec rails test:zeitwerk
```

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
