# Exercism Website

Exercism Website is a comprehensive Ruby on Rails application with React/TypeScript frontend that provides the main website for the Exercism platform. It's a complex application with multiple services, databases, and build processes.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

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
- Ruby version managers (rbenv/rvm) recommended for version management
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
The `/app/commands` directory contains command objects that encapsulate business logic using the Mandate gem. This pattern promotes:
- Single Responsibility Principle
- Testable business logic separation from controllers
- Consistent error handling and callbacks

#### Command Structure
Commands follow a consistent pattern:

```ruby
class User::Update
  include Mandate
  include Mandate::Callbacks  # Optional, for success/failure callbacks

  initialize_with :user, :params  # Defines constructor parameters

  def call  # Single public method that performs the operation
    some_guard!
    SomeModel.create(...).tap do |model|
      exec_callbacks!(model)
    end
  end

  private
  # Helper methods - use bang methods (foobar!) for anything that DOES something
  # Use normal methods for memoized values

  def some_guard!
    raise SomeError if invalid_condition?
  end

  memoize  # Caches the result of expensive operations
  def errors
    # Validation logic
  end
end
```

**Key principles:**
- The `call` method should be short and rely on memoized values and private methods
- Use `tap` to always return the created object when appropriate
- Use bang methods (`foobar!`) for anything that performs actions
- Use normal methods for memoized computed values
- Only the `call` method should be public

#### Calling Commands
Commands are invoked using the `.()` syntax:

```ruby
# Simple call
result = User::Update.(current_user, params)

# With callbacks (common in API controllers)
cmd = User::Update.(current_user, params)
cmd.on_success { render json: {} }
cmd.on_failure { |errors| render_400(:failed_validations, errors: errors) }
```

#### Key Patterns
- **`initialize_with`**: Defines constructor parameters
  - **Positional params**: For required parameters (e.g., `:user, :exercise`)
  - **Named params**: For optional parameters (e.g., `page: 1, per: 20`)
  - **`Mandate::NO_DEFAULT`**: For rare situations where a named parameter is required but has no sensible default
- **`memoize`**: Caches expensive computations like validation results
- **`call`**: Single public method that performs the main operation
- **Error handling**: Raise exceptions rather than using framework-specific methods like `abort!`
- **Callbacks**: `.on_success` and `.on_failure` for handling results

#### Common Command Types
- **Create commands**: `User::Create`, `Solution::Create`
- **Update commands**: `User::Update`, `Exercise::Update`
- **Query commands**: `Solution::Search`, `User::RetrieveAuthored`
- **Processing commands**: `Ansi::RenderHTML`, `Markdown::Parse`

### API, SPI and Route Architecture

#### API Routes (`/api`)
The API namespace provides public endpoints for authenticated users, primarily consumed by:
- Exercism Command Line Interface (CLI)
- Exercism website frontend
- Third-party integrations with proper authentication

API controllers delegate business logic to Mandate commands:

```ruby
class API::SettingsController < API::BaseController
  def update
    cmd = User::Update.(current_user, params)
    
    cmd.on_success { render json: {} }
    cmd.on_failure { |errors| render_400(:failed_validations, errors: errors) }
  end
end
```

Key characteristics:
- Requires authentication via Bearer tokens (`Authorization: Bearer <token>`)
- Returns JSON responses
- Handles errors consistently via `render_400`, `render_403`, etc.
- Routes defined in `config/routes/api.rb`

#### SPI Routes (`/spi`)
The Service Provider Interface (SPI) provides internal endpoints for:
- AWS Lambda functions
- Internal microservices
- Exercism infrastructure components

**Security Model**: SPI endpoints are secured at the AWS infrastructure level rather than application-level authentication, allowing trusted internal services to post data arbitrarily.

```ruby
# Example SPI endpoints
namespace :spi do
  resources :tooling_jobs, only: :update        # Tooling service updates
  resources :chatgpt_responses, only: :create   # AI service responses
  get "solution_image_data/:track_slug/:exercise_slug/:user_handle" => "solution_image_data#show"
end
```

Key characteristics:
- No application-level authentication required
- AWS-level security controls access
- Used by Lambda functions to post results back to main application
- Routes defined in `config/routes/spi.rb`

#### Standard Routes
Regular Rails routes handle:
- User-facing web pages
- Authentication flows (Devise)
- Webhooks (GitHub, Stripe, PayPal)
- Admin interfaces

Routes are organized in the main `config/routes.rb` with additional route files for specific features like bootcamp functionality.

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

### Model Tests
Model tests focus on testing every public method with small, focused tests. Tests should cover:
- **Happy path behavior**: Normal usage scenarios
- **Edge cases**: Boundary conditions and error states
- **Validations**: Ensure all model validations work correctly
- **Associations**: Test relationships between models
- **Scopes and queries**: Verify custom query methods

```ruby
class UserTest < ActiveSupport::TestCase
  test "reputation_for_track returns correct value" do
    user = create :user
    track = create :track
    create :user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 20 }
    
    assert_equal 20, user.reputation_for_track(track)
  end

  test "handles nil track gracefully" do
    user = create :user
    assert_equal 0, user.reputation_for_track(nil)
  end
end
```

### Command Tests  
Command tests follow the pattern: **setup, execute command, assert**. Focus on:
- **Happy path test**: One test for the main successful scenario
- **Edge case tests**: Every possible failure condition and boundary case
- **Idempotency**: Ensure commands can be run multiple times safely when applicable

```ruby
class Solution::CreateTest < ActiveSupport::TestCase
  test "creates concept solution successfully" do
    user = create :user
    exercise = create :concept_exercise
    create :user_track, user:, track: exercise.track
    UserTrack.any_instance.expects(:exercise_unlocked?).returns(true)

    solution = Solution::Create.(user, exercise)
    
    assert solution.is_a?(ConceptSolution)
    assert_equal user, solution.user
    assert_equal exercise, solution.exercise
  end

  test "raises when exercise is locked" do
    user = create :user
    exercise = create :concept_exercise
    create :user_track, user:, track: exercise.track
    UserTrack.any_instance.expects(:exercise_unlocked?).returns(false)

    assert_raises ExerciseLockedError do
      Solution::Create.(user, exercise)
    end
  end

  test "idempotent behavior" do
    user = create :user
    exercise = create :concept_exercise
    create :user_track, user:, track: exercise.track
    UserTrack.any_instance.expects(:exercise_unlocked?).returns(true).twice

    assert_idempotent_command { Solution::Create.(user, exercise) }
  end
end
```

### System Tests
System tests verify end-to-end user workflows using browser automation. They should:
- **Test complete user journeys**: From login to task completion
- **Verify UI interactions**: Button clicks, form submissions, navigation
- **Check visual feedback**: Success messages, error states, loading indicators
- **Use realistic test data**: Mirror production scenarios

```ruby
class UserRegistrationTest < ApplicationSystemTestCase
  test "user registers successfully" do
    visit new_user_registration_path
    fill_in "Email", with: "user@exercism.org"
    fill_in "Username", with: "user22"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"

    click_on "Sign Up", class: "test-sign-up-btn"

    assert_text "Check your email"
  end

  test "user sees validation errors" do
    visit new_user_registration_path
    fill_in "Email", with: "invalid-email"
    click_on "Sign Up"

    assert_text "Email is invalid"
  end
end
```

**System Test Guidelines:**
- Use descriptive test names that explain the user action
- Include both success and failure scenarios
- Use `wait` parameters for dynamic content loading
- Test accessibility and responsive behavior when relevant