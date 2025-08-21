# Exercism Website

Exercism Website is a comprehensive Ruby on Rails application with React/TypeScript frontend that provides the main website for the Exercism platform. It's a complex application with multiple services, databases, and build processes.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Documentation

There is a subdirectory called `docs/llm-support` which contains detailed information that an LLM might find useful on different areas of the application. When working with specific components, always reference the RELEVANT docs in that directory first:

- `API.md` - Detailed API architecture, authentication, and patterns
- `SPI.md` - Service Provider Interface for internal AWS services

These files provide comprehensive context that supplements the workflow guidance in this document.

## Working Effectively

### Prerequisites and Environment Setup
- Install Ruby 3.4.4 (REQUIRED - other versions will cause dependency conflicts)
- Install Node.js (validated with v20.19.4) and Yarn (validated with v1.22.22)
- Install MySQL 5.7, Redis, and Docker
- macOS: `brew install libgit2 cmake pkg-config anycable-go hivemind node yarn mysql redis docker`
- Ubuntu: `sudo apt-get install software-properties-common libmariadb-dev cmake ruby-dev ruby-bundler ruby-railties libvips nodejs yarn mysql-server redis-server docker.io`

### Bootstrap Dependencies
- Install Ruby dependencies: `bundle config set --local path 'vendor/bundle' && bundle install`
  - **TIMING: Takes 15-20 minutes due to native extensions (grpc, skylight, etc.). NEVER CANCEL.**
  - **WARNING: Requires Ruby 3.4.4 exactly - will fail with version mismatch**
- Install JavaScript dependencies: `yarn install`
  - **LIMITATION: Requires NPM_TOKEN for private packages (@juliangarnierorg/anime-beta)**
  - **WORKAROUND: In CI, the token is provided via secrets.NPM_TOKEN**
  - If authentication fails, document this limitation - some JS builds may not work

### Database and Services Setup
- Configure MySQL database:
  ```sql
  CREATE USER 'exercism'@'localhost' IDENTIFIED BY 'exercism';
  CREATE DATABASE exercism_development;
  ALTER DATABASE exercism_development CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  GRANT ALL PRIVILEGES ON exercism_development.* TO 'exercism'@'localhost';
  CREATE DATABASE exercism_test;
  ALTER DATABASE exercism_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  GRANT ALL PRIVILEGES ON exercism_test.* TO 'exercism'@'localhost';
  ```

- Start required Docker services:
  ```bash
  docker run -dp 3042:8080 -p 3040:4566 -p 3041:4566 localstack/localstack:2.3.2
  docker run -dp 9200:9200 -e "discovery.type=single-node" opensearchproject/opensearch:2.11.0
  ```

- Run Exercism-specific setup:
  ```bash
  EXERCISM_ENV=development bundle exec setup_exercism_config
  EXERCISM_ENV=development bundle exec setup_exercism_local_aws
  ```
  - **NOTE: Must run every time Docker services restart**

### Build Assets
- Build CSS: `yarn build:css` 
  - **TIMING: Initial build ~2-3 minutes, watch mode for development**
- Build JavaScript: `yarn build`
  - **TIMING: Initial build ~3-5 minutes, watch mode for development**
- Rails asset compilation: `bundle exec rails assets:precompile` (production)

### Running Tests
- Ruby tests: `bundle exec rails test`
  - **TIMING: Takes 10-15 minutes for full suite. NEVER CANCEL.**
  - **CI runs tests in parallel batches of 50 files each**
- JavaScript tests: `yarn test`
  - **TIMING: Takes 2-3 minutes**
- System tests: `bundle exec rails test test/system`
  - **TIMING: Takes 15-20 minutes with browser automation. NEVER CANCEL.**
  - **Requires Chrome/Selenium setup**

### Linting and Code Quality
- Ruby linting: `bundle exec rubocop --except Metrics`
  - Auto-fix: `bundle exec rubocop --except Metrics -a`
- JavaScript linting: `npx eslint app/javascript`
- HAML linting: `bundle exec haml-lint`
- **ALWAYS run linting before committing or CI will fail**

### Running the Development Server
Use `./bin/dev` to orchestrate all services:

```bash
./bin/dev
```

This script automatically:
- Clears built assets
- Starts required Docker services (LocalStack and OpenSearch)
- Installs JavaScript dependencies
- Runs all services via Procfile.dev using hivemind

#### Manual startup (all platforms)
**NOTE: This is very rarely necessary - use `./bin/dev` instead.**
```bash
# Terminal 1: Rails server
bundle exec rails server -p 3020

# Terminal 2: AnyCable
bundle exec anycable

# Terminal 3: Sidekiq
bundle exec sidekiq

# Terminal 4: WebSocket server
anycable-go --host='local.exercism.io' --rpc_host='local.exercism.io:50051' --port=3334

# Terminal 5: CSS build (watch mode)
yarn build:css --watch

# Terminal 6: JavaScript build (watch mode)
yarn build --watch
```

## Validation and Testing

### Manual Validation Requirements
After making changes, ALWAYS test core functionality:
1. Browse to http://localhost:3020
2. Test user registration/login flow
3. Navigate key sections (tracks, exercises, community)
4. Test JavaScript interactions (code editor, modals)
5. Verify CSS styling renders correctly

### Pre-commit Validation
ALWAYS run before committing (for changed files only):
```bash
bundle exec rubocop --except Metrics
yarn test
bundle exec rails test:zeitwerk
```

## Critical Warnings and Limitations

### Build Timing - NEVER CANCEL
- **Bundle install: 15-20 minutes** - Native extensions for grpc, skylight, commonmarker take time
- **Ruby test suite: 10-15 minutes** - Full suite with database operations
- **System tests: 15-20 minutes** - Browser automation with Capybara/Selenium
- **Asset builds: 2-5 minutes each** - CSS and JavaScript compilation

### Authentication Requirements
- **NPM Token required**: Private package access needs `NPM_TOKEN` environment variable
- **AWS LocalStack**: Required for S3, DynamoDB, and other AWS service mocking
- **Database credentials**: Must match config/database.yml settings

### Version Dependencies (CRITICAL)
- **Ruby 3.4.4**: Exact version required - Gemfile.lock specifies this
- **Node.js 20+**: Required for esbuild and modern JS features
- **MySQL 5.7**: Database schema depends on this version
- **Bundler 2.6.9**: Locked version in Gemfile.lock

### Known Limitations
- Ruby version managers (setup-ruby and chruby) recommended for version management
- Some JS packages require private NPM access (will fail in some environments)  
- Docker services must be running before Rails server starts
- Database must be properly configured with utf8mb4 collation
- Large codebase - initial setup can take 30+ minutes total

## Important Directories

### Application Structure
- `app/controllers/` - Rails controllers
- `app/models/` - ActiveRecord models and business logic
- `app/commands/` - Mandate command objects for business logic (see Command Pattern below)
- `app/javascript/` - React/TypeScript frontend code
- `app/css/` - PostCSS stylesheets with Tailwind
- `app/views/` - HAML view templates
- `test/` - All test files (unit, integration, system)
- `test/system/` - Capybara system tests
- `test/javascript/` - Jest test files

## Command Pattern with Mandate

**Exercism uses the command pattern for most business logic operations.** The `/app/commands` directory contains command objects that encapsulate business logic using the Mandate gem.

For comprehensive documentation on command structure, patterns, and implementation details, see [`docs/llm-support/commands.md`](../docs/llm-support/commands.md).

### API, SPI and Route Architecture

For detailed information about API and SPI architectures, see:
- [`docs/llm-support/API.md`](../docs/llm-support/API.md) - API endpoints, authentication, and patterns
- [`docs/llm-support/SPI.md`](../docs/llm-support/SPI.md) - Internal service endpoints and AWS integration

#### Quick Reference

#### API Routes (`/api`)

Public endpoints for authenticated users (CLI, frontend, third-party integrations)
- Require Bearer token authentication
- Delegate business logic to Mandate commands
- Consistent JSON error responses
- Routes defined in `config/routes/api.rb`

#### SPI Routes (`/spi`)

Internal endpoints for AWS Lambda functions and microservices
- No application-level authentication (secured at AWS infrastructure level)
- Used by Lambda functions to post results back to main application
- Routes defined in `config/routes/spi.rb`

#### Standard Routes

Regular Rails routes for user-facing web pages, authentication flows, webhooks, and admin interfaces.

### Configuration
- `config/database.yml` - Database configuration
- `Procfile.dev` - Development server orchestration
- `.dockerimages.json` - Docker service versions
- `package.json` - JavaScript dependencies and scripts
- `Gemfile` - Ruby dependencies

### Build System
- `app/javascript/esbuild.js` - JavaScript build configuration
- `postcss.config.js` - CSS build configuration
- `tailwind.config.js` - Tailwind CSS customization

## Common Tasks and Debugging

### Database Issues
- Reset database: `bundle exec rails db:drop db:create db:migrate db:seed`
- Check migrations: `bundle exec rails db:migrate:status`

### Asset Issues

- Clear assets: `rm -rf .built-assets/`
- Rebuild: `yarn build:css && yarn build`

### Service Issues
- Check Docker services: `docker ps`
- Restart LocalStack: `docker restart <localstack-container-id>`
- Check AnyCable: `bundle exec anycable --version`

### Common Error Patterns
- "Ruby version mismatch": Install Ruby 3.4.4 exactly
- "NPM authentication failed": Need NPM_TOKEN for private packages
- "Database connection failed": Check MySQL service and credentials
- "Asset compilation failed": Ensure Node.js and Yarn versions are compatible

This setup is complex but necessary for the full Exercism platform. When in doubt, refer to the CI configuration in `.github/workflows/tests.yml` for authoritative build commands and timing expectations.

## Testing Patterns

There are tests for models, commands, controllers, and system testing - check the docs in `docs/llm-support/testing/...` for comprehensive details when creating or amending tests.