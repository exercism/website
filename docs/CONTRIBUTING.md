# Contributing

This document outlines the philosophy behind this codebase, and specific standards and rules that the codebase follows.

**Please note: We are not currently accepting Pull Requests to this repository.**

## Development Philosophy

This codebase aims to achieve the following goals:

- Optimise for the principle of least surprise for developers
- Aim to reduce churn and reduce the amount of different files touched during a change.
- Reduce the likelihood of bugs.

We achieve these with the following:

- **Consistency:** All areas of the codebase should behave in the same way and follow the same rules.
- **Purpose:** Files, classes and methods should have clear single purposes.
- **Test coverage:** We target as close to 100% test coverage of moving parts (models, commands, etc) and anticipated paths in user interactions (e.g. normal usage or error states).

## Code Standards

These code standards follow the principle of "strong opinions, loosely held".
If something is in this file, we treat it as gospel - it should be adhered to strictly and everyone should respect it.
However, we acknowledge that our standards might be incorrect and questioning them is sensible, so we welcome discussion of them.
PRs to this document are welcome, and should be accompanied by changes to an example part of the codebase that would be affected.
Final decisions are made by @iHiD but should be revisited periodically to test them against new experience and data.

## API, SPI, and normal routes

Our API (Application Programming Interface) is a public JSON API.
It can be authenticated by either a session or by passing an authentication token.
It should be used by View Components when they want to retrieve data (e.g. when filtering solutions).
Non-trivial JSON should be returned via serializers.

The SPI (Secure Programming Interface) is a private JSON API.
It is used by other components in our architecture to pass messages and data around.
It is not accessible via the Internet.

All other "normal" routes redirect or render HTML.

## Controllers

Controllers should be "thin".
Each action should do at most one thing, retrieve at most one thing, and render/redirect.
To achieve this, controllers call out to Commands, which contain more complex functionality encapsualted in stand-alone procedures. This is known as the Command Pattern or the Interactor Pattern.
Even if an action doesn't need any instance variables, add an empty controller action for it. This allows us to have visibility on what actions have been implemented on that controller.

## Serializers

To ensure that data is represented in common ways, we use serializer objects.
For example, the data for the mentoring workspace would be represented via a serializer.
The HTML that renders the table as a React Component would use the serializer to generate the JSON for the initial React Component, and the API endpoint would use the same Serializer when the table's data is filtered.

- Serializers reside in `app/serializers`
- Each serializer is a Mandate Command that should return a hash.
- To directly retrieve the JSON for manual rendering `.to_json` can be called on the hash.

## Models

Models are light-weight database wrappers.
We treat models as highly-predictable, meaning that creating and updating models should not have side-effects.
We therefore use `before_xxx` and `after-xxx` blocks sparingly.
The only time that changing a model should change other data is if the model does not make sense without that other data.
For example, users should **always** have authentication tokens.
So `User.create` can resonably call `AuthToken.create` in its `after_create` block.
However, although submitting iterations should create notifications, because it is not essential for the existance of the iteration to make sense, `Iteration.create` would **not** be responsible for calling `Notification.create`.

Model's methods should not cause any side-effects that cannot be inferred from the method name.
They should be fast and cheap (in terms of \$\$$).
They should not interact with external services (such as s3) unless clear that they will do so from the method name.
For example `IterationFile#content` is currently a dangerous method, as calling `IterationFile.all.map(&:content)` costs $4 to run, which is not clear from the method name.

## Commands

Commands are the fundamental building blocks of the Domain Model whereas models represent the Data Models.
In practice that means that Commands are responsible for completing some sort of action that might touch different areas of the project.
For example, creating an iteration (`Iteration::Create.()`), creates multiple db records, writes to DynamoDB and S3, generates notifications and more.

Each Command should have responsibility for doing one domain action (e.g. creating or updating something).
It should then proxy other parts of that to other Commands (e.g. `Interation::Create` calls `Notification::Create`) or create records specifically under its ownership (e.g. `Iteration::Create.()` calling `Iteration.create()`.

Commands should be highly readable.
It should be extremely clear from reading the Command's `call` method what the Command does.

Commands should use [Mandate](https://github.com/iHiD/mandate).

Unless specified in their name, Commands should be agnostic to the source of the data.
For example, `Iteration::Create` should not care whether the files have come from the CLI or the editor.

Commands should follow naming pattern that follows: `#{DomainModel}::#{Action}`
For example: `Iteration::Create` or `ToolingJob::Process`

## View Components

We use view components to split the UI into stand-alone units that can be used and tested independently from the rest of the application.
View Components are either functional and written in React, or non-functional and rendered as HAML templates.

### React components

- The JS for each component lives in `app/javascript/components/**/XXX.js`
- The CSS for each component lives in `app/css/components/**/XXX.css`

#### Server-side component class

Each component has a class in `app/helpers/view_components/**/XXX.rb`

This component is responsible for rendering the component via its `to_s` method.
Any server-side properties of the component (e.g. sort options) should be stored within this class.

#### Testing components

The tests should cover all functionality in the component, with unit tests being via JS, and tests that interact with Rails being tested through system tests.

Each component should have a set of JavaScript tests.
These are written in Jest.
They reside in `test/javascript/**/XXX.test.js`

Each component should have a test file for its server-side component class.
This should test the component's div and initial data are rendered correctly.
These reside in `test/helpers/view_components/**/XXX_test.rb`

Each component has a view file for development usage and system testing.
These reside in `app/views/test/components/**/XXX.html.haml`

Finally, each component has Rails system tests.
These reside in `test/system/components/**/XXX_test.rb`

## Linting

Pre-commit linting should happen automatically via our [Husky hook](https://github.com/typicode/husky#husky).

### Ruby files

- Ruby files should adhere to the rules in `.rubocop.yml`
- We do not use "FrozenStringLiteral" comments.

### Markdown files

We use markdown files for documentation.

- Markdown files should adhere to the rules in `.prettierrc.json`.
- Each sentence should be on its own line.
- With the exception of files that have special meaning to GitHub (README.md, LICENCE.md, SECURITY.md), docs should be in the `docs/` folder.

### CSS files

- CSS files should adhere to the rules in `.prettierrc.json`.

### HAML files

- Haml files should adhere to the rules in `.haml-lint.yml`
- Note that haml-lint does not automatically fix problems.
