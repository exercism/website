# Contributing

## Development Philosophy

This codebase aims to achieve the following goals:

- Optimize for the principle of least surprise for developers
- Aim to reduce churn and reduce the amount of different files touched during a change
- Reduce the likelihood of bugs

We achieve these with the following:

- **Consistency:** All areas of the codebase should behave in the same way and follow the same rules
- **Purpose:** Files, classes and methods should have clear single purposes
- **Test coverage:** We target as close to 100% test coverage of moving parts (models, commands, etc) and anticipated paths in user interactions (e.g. normal usage or error states)

### Strong opinions, loosely help

These code conventions follow the principle of "strong opinions, loosely held".
If something is in this file, we treat it as gospel - it should be adhered to strictly and everyone should respect it.
However, we acknowledge that our conventions might be incorrect and questioning them is sensible, so we welcome discussion of them.
PRs to this document are welcome, and should be accompanied by changes to an example part of the codebase that would be affected.
Final decisions are made by @iHiD but should be revisited periodically to test them against new experience and data.

## Tests

Tests are crucial, first-class citizens in this codebase.
Where possible we adhere to Test Driven Development as our development methodology.

Our first priority is to avoid bugs and regressions.
Everything else is secondary to this goal.

Our second priority is to design tests in such a way that changes have minimal impacts.
For example, if we add one value to a serializer, we should only need to change that in the serializer test and the associated system test.
The easiest way to achieve this is to use serializers in the tests, e.g. [this PR change](https://github.com/exercism/website/pull/1975/files#diff-388f2123fefae40a9387b4929c8e1061c7358dac24b9032fdd7243ee04ae083a).

The third priority is speed.
Slow test-suites hurt.
Where possible avoid creating unnecessary DB records, or adding sleeps to fix sporadic system tests.
But do not make changes that speed things up, but reduce test-coverage or robustness.

For complex objects (e.g. serializers, view components), create one test for the "happy" path, and then subsequent tests for variables that may change.
For example, create a test for the serialization of a default factory, which tests the full JSON, then create subsequent tests for different parts of that serialization where parts of the data change.

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
Each action should either do something or retrieve something then render/redirect.
To achieve this, controllers call out to Commands, which contain more complex functionality encapsulated in stand-alone procedures. This is known as the Command Pattern or the Interactor Pattern.
Even if an action doesn't need any instance variables, add an empty controller action for it. This allows us to have visibility on what actions have been implemented on that controller.

### Authentication

By default, all controllers expect a user to be authenticated, and return a user to the log in page if they are not.
This can be overridden using the `skip_before_action authenticate_user!` method.

## Serializers

To ensure that data is represented in common ways, we use serializer objects.
For example, the data for the mentoring inbox would be represented via a serializer.
The HTML that renders the table as a React Component would use the serializer to generate the JSON for the initial React Component, and the API endpoint would use the same Serializer when the table's data is filtered.

- Serializers reside in `app/serializers`
- Each serializer is a Mandate Command that should return a hash.
- To directly retrieve the JSON for manual rendering `.to_json` can be called on the hash.

## Models

Models are light-weight database wrappers.

We treat models as highly-predictable, meaning that creating and updating models should not have side-effects.
We therefore use `before_xxx` and `after_xxx` blocks sparingly.
The only time that changing a model should change other data is if the model does not make sense without that other data.
For example, users should **always** have authentication tokens.
So `User.create` can reasonably call `AuthToken.create` in its `after_create` block.
In contrast, although submitting submissions should create notifications, because it is not essential for the existence of the submission to make sense, `Submission.create` would **not** be responsible for calling `Notification.create`.

Some other conventions:

- Model's methods should not cause any side-effects that cannot be inferred from the method name.
- They should be fast and cheap (in terms of \$\$\$).
- They should not interact with external services (such as s3) unless clear that they will do so from the method name.
  For example `SubmissionFile#content` is currently a dangerous method, as calling `SubmissionFile.all.map(&:content)` costs \$4 to run, which is not clear from the method name.

## Commands

Commands are the fundamental building blocks of the Domain Model whereas models represent the Data Models.
In practice that means that Commands are responsible for completing some sort of action that might touch different areas of the project.
For example, creating an submission (`Submission::Create.(...)`), creates multiple db records, writes to DynamoDB and S3, generates notifications and more.

Each Command should have responsibility for doing one domain action (e.g. creating or updating something).
It should then proxy other parts of that to other Commands (e.g. `Interaction::Create` calls `Notification::Create`) or create records specifically under its ownership (e.g. `Submission::Create.()` calling `Submission.create()`.

The `call` method of a command should be focussed on clarity.
It should be extremely clear from reading that method what the Command does.
More complex functionality should be split out into private methods.

Commands should use [Mandate](https://github.com/iHiD/mandate).

Commands should follow naming pattern that follows: `#{DomainModel}::#{Action}`
For example: `Submission::Create` or `ToolingJob::Process`

Unless specified in their name, Commands should be agnostic to the source of the data.
For example, `Submission::Create` should not care whether the files have come from the CLI or the editor.

## View Components

We use View Components to split the UI into stand-alone units that can be used and tested independently from the rest of the application.
View Components are non-functional and rendered as HAML templates.

Each View Component has a class in Rails which is used to render it in a consistent manner, and through which any initial data or configuration can be passed.

- The JS for each component lives in `app/javascript/components/view_components/xxx_yyy.js`.
- The CSS for each component lives in `app/css/components/xxx_yyy.css`.

### CSS

- All top-level components (those intended to be rendered directly from a view) should have a className set to `c-#{component-name}`, e.g. `c-track-list`, where `c-` indicates a component.
- All CSS for the components must be nested within that component using CSS 3 nesting.
- Tags should be semantic.

### React components

React components are used for UI that contains interactivity.

- The JS for each component lives in `app/javascript/components/react_component/xxx_yyy.js`.
- The CSS for each component lives in `app/css/components/xxx_yyy.css`.
- React components are named using PascalCase (e.g. `app/javascript/components/common/MarkdownEditor.js`)

#### Server-side component class

Each React Component has a corresponding Rails class, which lives in `app/helpers/react_components/**/xxx.rb`.
This class uses the default Ruby naming conventions (e.g. `app/helpers/react_components/common/markdown_editor.rb`).

This class should defined a `#to_s` method, which is responsible for rendering HTML with relevant attributes.
This is generally achieved by calling the `super` method on the (parent) `ReactComponents::ReactComponent` class (located in `app/helpers/react_components/react_component.rb`), which generates a `div` with a data attribute for the react component's name (e.g. `data-react-tracks-list` for the `tracks-list` component) and a `data-react-data` containing any data that the Component needs to initialize.

The React Component should also encapsulate any server-side properties should be stored within this class, such as sort options.

If the component requires serialization of data that is not provided via a common serializer, it should define its own serializer within the class, e.g. [in the mentoring session](https://github.com/exercism/website/blob/3dc102f1c9be80f028d8d3f5d9fa4d1690b5d69c/app/helpers/react_components/mentoring/session.rb#L100)

#### Testing components

The tests should cover all functionality in the component, with unit tests being via JS, and tests that interact with Rails being tested through system tests.

Each Component should have a set of JavaScript tests.
These are written in Jest.
They reside in `test/javascript/**/XXX.test.js` (e.g. `test/javascript/components/common/MarkdownEditor.test.js`).

Each Component should have a test file for its server-side View Component class.
This should test the component's div and initial data are rendered correctly.
These reside in `test/helpers/view_components/**/XXX_test.rb`.
See `test/helpers/view_components/mentoring/inbox_test.rb` for an idiomatic example.

Each Component has a route and view to enable it be rendered both for development usage and system testing.
The routes live in the `test` namespace of the `config.routes`
The views live in `app/views/test/components/**/XXX.html.haml`.
The controllers live in `app/controllers/test/components/**/XXX_controller.rb` and should inherit from `Test::BaseController`.
The Component can be then accessed through `http://localhost:3020/test/components/...`
See `app/controllers/test/components/common/copy_to_clipboard_button_controller.rb` for an idiomatic example.

Finally, each Component has Rails system tests, which test the correct HTML is rendered.
These reside in `test/system/components/**/XXX_test.rb`.
See `test/system/components/student/tracks_list_test.rb` for an idiomatic example.

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

## Libraries Used

This is a reference of the libraries we use:

- **JS Keyboard shortcuts:** Mousetrap
