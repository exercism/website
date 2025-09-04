# Exercism Website

Exercism Website is a comprehensive Ruby on Rails application with React/TypeScript frontend that provides the main website for the Exercism platform. It's a complex application with multiple services, databases, and build processes.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Documentation

There is a subdirectory called `docs/context` which contains detailed information that an LLM might find useful on different areas of the application. When working with specific components, always reference the RELEVANT docs in that directory first:

- `running-the-app.md` - Complete guide for environment setup, dependencies, and running the application
- `API.md` - Detailed API architecture, authentication, and patterns
- `SPI.md` - Service Provider Interface for internal AWS services
- `commands.md` - Complete Command Pattern documentation with Mandate gem usage
- `serializers.md` - Data serialization patterns for JSON API responses
- `assemblers.md` - Data assembly patterns for consistent API and SSR responses
- `view-components.md` - Server-side component architecture with encapsulated logic
- `react-components.md` - Client-side React component integration and data passing
- `testing/` - Comprehensive testing patterns for models, commands, controllers, and system tests

These files provide comprehensive context that supplements the workflow guidance in this document.

## Working Effectively

For comprehensive guidance on environment setup, dependency installation, building assets, running tests, and starting the development server, see [`docs/context/running-the-app.md`](docs/context/running-the-app.md).

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

For comprehensive documentation on command structure, patterns, and implementation details, see [`docs/context/commands.md`](docs/context/commands.md).

### API, SPI and Route Architecture

For detailed information about API and SPI architectures, see:

- [`docs/context/API.md`](docs/context/API.md) - API endpoints, authentication, and patterns
- [`docs/context/SPI.md`](docs/context/SPI.md) - Internal service endpoints and AWS integration

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

There are tests for models, commands, controllers, and system testing - check the docs in `docs/context/testing/...` for comprehensive details when creating or amending tests.
