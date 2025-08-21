**Please note: This repo is an internal repo. That means the source code is public, but we do not accept Pull Requests, we do not support the app being run locally, and we do not encourage people to fork or reuse this repository.**

---

# Exercism

![Tests](https://github.com/exercism/website/workflows/Tests/badge.svg)
[![Maintainability](https://api.codeclimate.com/v1/badges/b47ec4d5081d8abb59fa/maintainability)](https://codeclimate.com/github/exercism/website/maintainability)
[![View performance data on Skylight](https://badges.skylight.io/typical/VNpB7GqXZDpQ.svg)](https://oss.skylight.io/app/applications/VNpB7GqXZDpQ)

This is the website component of Exercism.
It is Ruby on Rails app, backed by various other services.

## Setup

These are instructions to get things working locally.
While you are welcome to try and follow these instructions and set up this repo on your local machine, we provide no guarantee of things working on your specific local setup.

### Prerequistes

You need the following installed:

- Ruby 3.3.0 (For other Ruby versions, change the version in the `Gemfile` and the `.ruby-version` files)
- MySQL
- MongoDB
- Redis
- [AnyCable-Go](https://github.com/anycable/anycable-go#installation)
- [Docker](https://www.docker.com/)

#### Mac-specific

The main dependencies can be installed via homebrew

- `brew install libgit2 cmake pkg-config anycable-go hivemind node yarn`

#### Unix-specific

What dependencies you need to install depends on your Unix distribution.

For example, for Ubuntu you'll need to install:

`sudo apt-get install software-properties-common libmariadb-dev cmake ruby-dev ruby-bundler ruby-railties`

You'll also need to install [nodejs](https://nodejs.org/en/download/) and [yarn](https://yarnpkg.com/getting-started/install).

#### Windows-specific

As we recommend using WSL, see the Unix-specific instructions listed above.

For information on setting up WSL, check [the installation instructions](https://docs.microsoft.com/en-us/windows/wsl/install).

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

### Running local AWS

To run the app you must have a local version of AWS running.
We use localstack and opensearch, and run them via Docker.
Double check versions in `.dockerimages.json`.

```bash
docker run -dp 3042:8080 -p 3040:4566 -p 3041:4566 localstack/localstack:2.3.2
docker run -dp 9200:9200 -e "discovery.type=single-node" opensearchproject/opensearch:2.11.0
```

### Run the setup script

The following scripts configure exercism to work with your setup.

```
bundle install
EXERCISM_ENV=development bundle exec setup_exercism_config
EXERCISM_ENV=development bundle exec setup_exercism_local_aws
```

**Note: you will need to do this every time you reset dynamodb, which happens when Docker is restarted.**

### Running the local servers

We have a Procfile which executes the various commands need to run Exercism locally.

#### Mac-specific

On MacOSX we recommend using `hivemind` to manage this, which can be installed via `brew install hivemind`.

To get everything started you can then run:

```bash
hivemind -p 3020 Procfile.dev
```

#### Unix-specific

On Unix systems we recommend using `overmind` to manage this, which can be installed using [these instructions](https://github.com/DarthSim/overmind#installation).

To get everything started you can then run:

```bash
overmind start --port 3020 --procfile Procfile.dev
```

#### Windows-specific

As we recommend using WSL, see the Unix-specific instructions listed above.

For information on setting up WSL, check [the installation instructions](https://docs.microsoft.com/en-us/windows/wsl/install).

## Rails Console

The Rails 7 console has autocomplete that can be very frustrating.
To disable it, do the following:

```
echo 'IRB.conf[:USE_AUTOCOMPLETE] = false' >> ~/.irbrc
```

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

### Running Jest tests

##### Run tests:

```
yarn test [path/to/file]
```

> Omit path to run all tests

##### Update snapshots:

```
yarn test [path/to/file] -- -u
```

> Omit path to update all snapshots

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

## Solargraph

Solargraph allows for code suggestions to appear in your editor.

If you'd like to use solargraph, the gem is in the file.
You need to run and set `solargraph.useBundler` to `true` in your config. I have this working well with coc-solargraph. [This article](http://blog.jamesnewton.com/setting-up-coc-nvim-for-ruby-development) was helpful for setting it up.

- `bundle exec yard gems`
- `solargraph bundle`
