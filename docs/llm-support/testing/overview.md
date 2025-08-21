# Testing Overview

> **Related Documentation**: See separate files in this directory for detailed patterns:
> - [`model-tests.md`](./model-tests.md) - Model testing patterns and examples
> - [`command-tests.md`](./command-tests.md) - Command testing with setup/execute/assert pattern
> - [`controller-tests.md`](./controller-tests.md) - API and web controller testing patterns
> - [`system-tests.md`](./system-tests.md) - End-to-end browser automation testing

Exercism uses **Minitest** as the testing framework with **FactoryBot** for test data generation. Tests are organized by type with comprehensive helper methods to support different testing scenarios.

## Testing Tools and Setup

**Core Testing Stack:**
- **Minitest**: Ruby's standard testing framework with assertions and test structure
- **FactoryBot**: Flexible test data generation with realistic factory definitions
- **Mocha**: Mocking and stubbing framework for isolating tests
- **Capybara**: Browser automation for system tests
- **WebMock**: HTTP request stubbing for external service integration

**Test Data Management:**
- Factories defined in `test/factories/` directory
- Use `create :user` for persisted records, `build :user` for unsaved objects
- Factory traits available for common variations: `create :user, :admin`
- Consistent data patterns ensure realistic test scenarios