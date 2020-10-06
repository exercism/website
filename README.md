# Exercism

![Tests](https://github.com/exercism/v3-website/workflows/Tests/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/b47ec4d5081d8abb59fa/maintainability)](https://codeclimate.com/github/exercism/v3-website/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b47ec4d5081d8abb59fa/test_coverage)](https://codeclimate.com/github/exercism/v3-website/test_coverage)

This is the WIP website for Exercism v3. We are not currently accepting Pull Requests to this repository.

This is the website component of Exercism. It is Ruby on Rails app, backed by MySQL. It also relies on Redis and AnyCable.

## Running within our development-environment

Our supported development setup is via our [development environment](https://github.com/exercism/development-environment) repo. Please follow the instructions there. _You can also run locally without Docker, but this is unsupported - see the next section for details._

### Setup database

Assuming your docker-compose is already "up," you can run the following commands from the `development-environment` directory to setup the database. All these are run "inside" the existing `website` container that needs to already have been started.

```sh
# seed the database
./bin/script website seed-db

# reset the database (drop -> migrate -> seed)
./bin/script website reset-db
```

### Running tests

Assuming your docker-compose is already "up," you can run the following commands from the `development-environment` directory to run tests. All these are run "inside" the existing `website` container that needs to already have been started.

```sh
# run rubocop to lint the codebase
./bin/script website lint

# run rake test
./bin/script website run-tests

# run rake test:system
./bin/script website run-system-tests

# run yarn test
./bin/script website run-js-tests
```

### Local setup

The website can be also be setup and run locally. This is unsupported.
You need the following installed:

- Ruby 2.6.6 (For other Ruby versions, change the version in the `Gemfile`)
- MySQL
- Redis
- [AnyCable-Go](https://github.com/anycable/anycable-go#installation)
- [DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html)
- [S3Mock](https://github.com/adobe/s3mock)

Run DynamoDB on port 3040 locally:

```
docker run -dp 3040:8000 amazon/dynamodb-local
```

Run S3Mock on port 3041 locally:

```
docker run -dp 3041:9090 adobe/s3mock
```

#### Mac-Specific

The main dependencies can be installed via homebrew

- `brew install libgit2 cmake pkg-config anycable-go hivemind`

#### Configure the database

Running these commands inside a mysql console will get a working database setup:

```bash
CREATE USER 'exercism_v3'@'localhost' IDENTIFIED BY 'exercism_v3';
CREATE DATABASE exercism_v3_development;
ALTER DATABASE exercism_v3_development CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON exercism_v3_development.* TO 'exercism_v3'@'localhost';

CREATE DATABASE exercism_v3_dj_development;
ALTER DATABASE exercism_v3_dj_development CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON exercism_v3_dj_development.* TO 'exercism_v3'@'localhost';

CREATE DATABASE `exercism_v3_test`;
ALTER DATABASE `exercism_v3_test` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `exercism_v3_test`.* TO 'exercism_v3'@'localhost';
```

Tests are parallelized so you need a db per processor, so you need to do this for `n` processors.

```bash
GRANT ALL PRIVILEGES ON `exercism_v3_test-0`.* TO 'exercism_v3'@'localhost';
```

#### Run the setup script

Run the setup scripts:

```
bundle install
EXERCISM_ENV=development bundle exec setup_exercism_config
EXERCISM_ENV=development bundle exec setup_exercism_local_aws
```

**Note: you will need to do this every time you reset dynamodb, which happens when Docker is restarted.**

#### Running the local servers

We have a Procfile which executes the various commands need to run Exercism locally.
On MacOSX we recommend using `hivemind` to manage this, which can be installed via `brew install hivemind`.

To get everything started you can then run:

```bash
hivemind -p 3020 Procfile.dev
```

## Configure Solargraph

If you'd like to use solargraph, the gem is in the file. You need to run and set `solargraph.useBundler` to `true` in your config. I have this working well with coc-solargraph. [This article](http://blog.jamesnewton.com/setting-up-coc-nvim-for-ruby-development) was helpful for setting it up.

- `bundle exec yard gems`
- `solargraph bundle`

## Code Standards

Rubocop is enforced on Pull Requests. To run it locally:

```
bundle exec rubocop --except Metrics
```

To autoupdate based on it's suggestions, add the `-a` flag:

```
bundle exec rubocop --except Metrics -a
```

To check the complexity of your code and ensure you're not
adding things that are more complex to the codebase, run without the `--except` flag:

```
bundle exec rubocop -a
```

## Testing

The tests can be run using:

```
bundle exec rake test
```

### Git Repos

If you need to create a new Git repo for use in the tests, use the following:

```
mkdir /Users/iHiD/Code/exercism/v3/test/repos/new-repo
cd /Users/iHiD/Code/exercism/v3/test/repos/new-repo
git init --bare

cd ~
git clone file:///Users/iHiD/Code/exercism/v3/test/repos/new-repo exercism-new-git-repo
cd exercism-new-git-repo
echo "{}" > config.json
git add config.json
git commit -m "First commit"
git push origin head
```
