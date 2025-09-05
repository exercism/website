# Running the Exercism Application

## Prerequisites and Environment Setup

- Install Ruby 3.4.4 (REQUIRED - other versions will cause dependency conflicts)
- Install Node.js (validated with v20.19.4) and Yarn (validated with v1.22.22)
- Install MySQL 5.7, Redis, and Docker
- macOS: `brew install libgit2 cmake pkg-config anycable-go hivemind node yarn mysql redis docker`
- Ubuntu: `sudo apt-get install software-properties-common libmariadb-dev cmake ruby-dev ruby-bundler ruby-railties libvips nodejs yarn mysql-server redis-server docker.io`

## Bootstrap Dependencies

- Install Ruby dependencies: `bundle config set --local path 'vendor/bundle' && bundle install`
  - **TIMING: Takes 15-20 minutes due to native extensions (grpc, skylight, etc.). NEVER CANCEL.**
  - **WARNING: Requires Ruby 3.4.4 exactly - will fail with version mismatch**
- Install JavaScript dependencies: `yarn install`
  - **LIMITATION: Requires NPM_TOKEN for private packages (@juliangarnierorg/anime-beta)**
  - **WORKAROUND: In CI, the token is provided via secrets.NPM_TOKEN**
  - If authentication fails, document this limitation - some JS builds may not work

## Database and Services Setup

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

## Build Assets

- Build CSS: `yarn build:css`
  - **TIMING: Initial build ~2-3 minutes, watch mode for development**
- Build JavaScript: `yarn build`
  - **TIMING: Initial build ~3-5 minutes, watch mode for development**
- Rails asset compilation: `bundle exec rails assets:precompile` (production)

## Running Tests

- Ruby tests: `bundle exec rails test`
  - **TIMING: Takes 10-15 minutes for full suite. NEVER CANCEL.**
  - **CI runs tests in parallel batches of 50 files each**
- JavaScript tests: `yarn test`
  - **TIMING: Takes 2-3 minutes**
- System tests: `bundle exec rails test test/system`
  - **TIMING: Takes 15-20 minutes with browser automation. NEVER CANCEL.**
  - **Requires Chrome/Selenium setup**

## Linting and Code Quality

- Ruby linting: `bundle exec rubocop --except Metrics`
  - Auto-fix: `bundle exec rubocop --except Metrics -a`
- JavaScript linting: `npx eslint app/javascript`
- HAML linting: `bundle exec haml-lint`
- **ALWAYS run linting before committing or CI will fail**

## Running the Development Server

Use `./bin/dev` to orchestrate all services:

```bash
./bin/dev
```

This script automatically:

- Clears built assets
- Starts required Docker services (LocalStack and OpenSearch)
- Installs JavaScript dependencies
- Runs all services via Procfile.dev using hivemind

### Manual startup (all platforms)

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
