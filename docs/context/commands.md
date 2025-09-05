# Command Pattern with Mandate

> **Related Documentation**: See [`API.md`](./API.md) and [`SPI.md`](./SPI.md) for how commands are used in API and SPI controllers.

The `/app/commands` directory contains command objects that encapsulate business logic using the Mandate gem. This pattern promotes:

- Single Responsibility Principle
- Testable business logic separation from controllers
- Consistent error handling and callbacks

## Command Structure

Commands follow a consistent pattern:

```ruby
class User::Update
  include Mandate
  include Mandate::Callbacks  # Optional, for success/failure callbacks

  initialize_with :user, :params  # Defines constructor parameters

  def call  # Single public method that performs the operation
    some_guard!
    SomeModel.create(...).tap do |model|
      exec_callbacks!(model)
    end
  end

  private
  # Helper methods - use bang methods (foobar!) for anything that DOES something
  # Use normal methods for memoized values

  def some_guard!
    raise SomeError if invalid_condition?
  end

  memoize  # Caches the result of expensive operations
  def errors
    # Validation logic
  end
end
```

**Key principles:**

- The `call` method should be short and rely on memoized values and private methods
- Use `tap` to always return the created object when appropriate
- Use bang methods (`foobar!`) for anything that performs actions
- Use normal methods for memoized computed values
- Only the `call` method should be public

## Calling Commands

Commands are invoked using the `.()` syntax:

```ruby
# Simple call
result = User::Update.call(current_user, params)

# With callbacks (common in API controllers)
cmd = User::Update.call(current_user, params)
cmd.on_success { render json: {} }
cmd.on_failure { |errors| render_400(:failed_validations, errors: errors) }
```

## Key Patterns

- **`initialize_with`**: Defines constructor parameters
  - **Positional params**: For required parameters (e.g., `:user, :exercise`)
  - **Named params**: For optional parameters (e.g., `page: 1, per: 20`)
  - **`Mandate::NO_DEFAULT`**: For rare situations where a named parameter is required but has no sensible default
- **`memoize`**: Caches expensive computations like validation results
- **`call`**: Single public method that performs the main operation
- **Error handling**: Raise exceptions rather than using framework-specific methods like `abort!`
- **Callbacks**: `.on_success` and `.on_failure` for handling results

## Common Command Types

- **Create commands**: `User::Create`, `Solution::Create`
- **Update commands**: `User::Update`, `Exercise::Update`
- **Query commands**: `Solution::Search`, `User::RetrieveAuthored`
- **Processing commands**: `Ansi::RenderHTML`, `Markdown::Parse`
