# Contributing

This document outlines the philosophy behind this codebase, and specific standards and rules that the codebase follows.

**Please note: We are not currently accepting Pull Requests to this repository.**

## Development Philosophy

This codebase aims to achieve the following goals:

- Optimise for the principle of least surprise for developers
- Aim to reduce churn and reduce the amount of different files touched during a change.
- Reduce the likelyhood of bugs.

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
To achieve this, controllers call out to Commands, which contain more complex functionality encapsualted in stand-alone procedures. This is know as the Command Pattern or the Interactor Pattern.

## Serializers

To ensure that data is represented in common ways, we use serializers.
For example, the data for the mentoring workspace would be represented via a serializer.
The HTML that renders the table as a React Component would use the serializer to generate the JSON for the initial React Component, and the API endpoint would use the same Serializer when the table's data is filtered.

## Models

Models are light-weight database wrappers.
We treat models as highly-predictable, meaning that creating and updating models should not have side-effects.
We therefore use `before_xxx` and `after-xxx` blocks sparsely.
The only time that changing a model should change other data is if the model does not make sense without that other data.
For example, users should **always** have authentication tokens.
So `User.create` can resonably call `AuthToken.create` in its `after_create` block.
However, although submitting iterations should create notifications, because it is not essential for the existance of the iteration to make sense, `Iteration.create` would **not** be responsible for calling `Notification.create`.

Model's methods should not cause any side-effects that cannot be infered from the method name.
They should be fast and cheap (in terms of \$\$$).
They should not interact with external services (such as s3) unless clear that they will do so from the method name.
For example `IterationFile#content` is currently a dangerous method, as calling `IterationFile.all.map(&:content)` costs $4 to run, which is not clear from the method name.

## Commands

## View Components

We use view components to split the UI into stand-alone units that can be used and tested independently from the rest of the application.
View Components are either functional and written in React, or non-functional and rendered as HAML templates.

### React components

- The JS for each component lives in `app/javascript/components/**/XXX.js`
- The CSS for each component lives in `app/css/components/**/XXX.css`
- Each component has a method in `app/helpers/components_helper.rb`
- Each component has a view file for development usage and system testing in `/app/views/test/components/**/XXX.html.haml`
- Each component has Rails system test in `test/system/components/**/XXX.rb`
- Each component has Jest test in `test/system/javascript/**/XXX.rb`

The tests should cover all functionality in the component, with unit tests being via JS, and tests that interact with Rails being tested through system tests.

## Markdown files

We use markdown files for documentation.

- Markdown files should adhere to the rules in `.prettierrc.json`.
- Each sentence should be on its own line.
- With the exception of files that have special meaning to GitHub (README.md, LICENCE.md, SECURITY.md), docs should be in the `docs/` folder.

## CSS files

- CSS files should adhere to the rules in `.prettierrc.json`.
