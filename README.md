# Exercism

![Tests](https://github.com/exercism/v3-website/workflows/Tests/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/b47ec4d5081d8abb59fa/maintainability)](https://codeclimate.com/github/exercism/v3-website/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b47ec4d5081d8abb59fa/test_coverage)](https://codeclimate.com/github/exercism/v3-website/test_coverage)

This is the WIP website for Exercism v3. We are not currently accepting Pull Requests to this repository.

This is the website component of Exercism. It is Ruby on Rails app, backed by MySQL. It also relies on Redis and AnyCable.

## Local Setup

The website can be run natively, through Docker, or as part of a wider Docker-compose with mysql, redis etc. All options have tradeoffs and the Core Team make use of all three approaches. The various options are outlined below.

If you are looking to create a full Exercism setup locally, with tooling such as test-runners and other services, please check out our [development environment instructions](./DEV_ENVIRONMENT.md).

### Using Docker

To build the Dockerfile, run:

```
docker build -f Dockerfile.dev -t exercism-website .
```

To execute the Dockerfile, run the following with your AWS keys:

```
./bin/run-docker
```

### Using Docker Compose

To use the Docker Compose file, run:

```
docker-compose up
```

### Local setup

You need the following installed:

- MySQL
- Redis
- [AnyCable-Go](https://github.com/anycable/anycable-go#installation)
- [DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html)
- [S3Proxy](https://github.com/gaul/s3proxy)

Run DynamoDB on port 3040 locally:

```
docker run -dp 3040:8000 amazon/dynamodb-local
```

Run S3Proxy on port 3041 locally:

```
docker run -dp 3041:80 --env S3PROXY_AUTHORIZATION=none --env LOG_LEVEL=debug andrewgaul/s3proxy
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
brew exec rake test
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
