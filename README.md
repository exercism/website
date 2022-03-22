# Exercism

![Tests](https://github.com/exercism/website/workflows/Tests/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/b47ec4d5081d8abb59fa/maintainability)](https://codeclimate.com/github/exercism/website/maintainability)
[![View performance data on Skylight](https://badges.skylight.io/typical/VNpB7GqXZDpQ.svg)](https://oss.skylight.io/app/applications/VNpB7GqXZDpQ)

This is the website component of Exercism. It is Ruby on Rails app, backed by MySQL. It also relies on Redis and AnyCable.

## Local setup

The website can be be setup and run locally, but this is unsupported.

You need the following installed:

- Ruby 3.1.0 (For other Ruby versions, change the version in the `Gemfile`)
- MySQL
- Redis
- [AnyCable-Go](https://github.com/anycable/anycable-go#installation)
- [DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html)
- [S3Mock](https://github.com/adobe/s3mock)

Run localstack for a local AWS, and opensearch via Docker:

```bash
docker run -dp 3042:8080 -p 3040:4566 -p 3041:4566 localstack/localstack
docker run -dp 9200:9200 -e "discovery.type=single-node" opensearchproject/opensearch:1.1.0
```

### Mac-Specific

The main dependencies can be installed via homebrew

- `brew install libgit2 cmake pkg-config anycable-go hivemind`

### Configure the database

Running these commands inside a mysql console will get a working database setup:

```bash
CREATE USER 'exercism'@'localhost' IDENTIFIED BY 'exercism';
CREATE DATABASE exercism_development;
ALTER DATABASE exercism_development CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON exercism_development.* TO 'exercism'@'localhost';

CREATE DATABASE `exercism_test`;
ALTER DATABASE `exercism_test` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `exercism_test`.* TO 'exercism'@'localhost';
```

Tests are parallelized so you need a db per processor, so you need to do this for `n` processors.

```bash
GRANT ALL PRIVILEGES ON `exercism_test-0`.* TO 'exercism'@'localhost';
```

#### Run the setup script

Run the setup scripts:

```
bundle install
EXERCISM_ENV=development bundle exec setup_exercism_config
EXERCISM_ENV=development bundle exec setup_exercism_local_aws
```

**Note: you will need to do this every time you reset dynamodb, which happens when Docker is restarted.**

### Running the local servers

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
bundle exec rails test
```

### Git Repos

If you need to create a new Git repo for use in the tests, use the following:

```
mkdir /Users/iHiD/Code/exercism/website/test/repos/new-repo
cd /Users/iHiD/Code/exercism/website/test/repos/new-repo
git init --bare

cd ~
git clone file:///Users/iHiD/Code/exercism/website/test/repos/new-repo exercism-new-git-repo
cd exercism-new-git-repo
echo "{}" > config.json
git add config.json
git commit -m "First commit"
git push origin head
```
