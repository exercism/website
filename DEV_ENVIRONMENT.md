# Development Environment

Exercism is a large open-source project. It is made up of over 250 repositories. Creating a full local setup is entirely manageable, but will involve some effort. This guide talks you through the steps needed. In many cases it will defer to sub-project repos.

## Exercism Website

The world-facing website.

- **Repo:** [exercism/v3-website](https://github.com/exercism/v3-website)
- **Architecture:** A Ruby on Rails application, backed by MySQl and Redis.
- **Behaviours:**
  - Web server on 3020

The website can be run locally, via Docker or via Docker Compose. Depending on your existing local setup, you might prefer any of those options. We recommend working through the website's README for instructions.

## Tooling Orchestrator

An internal service that queues tooling jobs (test-runs, analyzers, etc) and provides the link between the website and the invokers.

- **Repo:** [exercism/tooling-orchestrator](https://github.com/exercism/tooling-orchestrator)
- **Architecture:** A Ruby Sinatra application.
- **Behaviours:**
  - Web server on 3021

## Tooling Invoker

An internal service that executes test-runners, analyzers and representers.

- **Repo:** [exercism/tooling-invoker](https://github.com/exercism/tooling-invoker)
- **Architecture:** A Ruby service.
- **Behaviours:**
  - Loops listening to messages from the tooling-orchestrator, processes them, and returns the results to the orchestrator. In production this runs on EC2 and executes tooling via calls to `runc`. Locally it runs the checked out tooling.
