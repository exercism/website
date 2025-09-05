# API Architecture

> **Related Documentation**: See [`SPI.md`](./SPI.md) for internal service endpoints and [`commands.md`](./commands.md) for the command pattern used in API controllers.

The API namespace (`/api`) provides public endpoints for authenticated users and external integrations. This document details the architecture, authentication patterns, and implementation guidelines.

## Overview

The API serves as the primary interface for:

- **Exercism Command Line Interface (CLI)**: All CLI commands interact through these endpoints
- **Exercism website frontend**: Dynamic content loading and user interactions
- **Third-party integrations**: Partner applications and external tools with proper authentication

## Authentication Model

### Bearer Token Authentication

All API endpoints require authentication via Bearer tokens:

```http
Authorization: Bearer <user_auth_token>
```

### Token Management

- Tokens are managed through the `UserAuthToken` model
- Users can have multiple active tokens for different devices/applications
- Tokens can be revoked individually for security
- CLI automatically manages token storage and renewal

## Architecture Patterns

### Command Delegation Pattern

API controllers act as thin wrappers that delegate business logic to Mandate commands:

```ruby
class API::SettingsController < API::BaseController
  def update
    cmd = User::Update.call(current_user, params)

    cmd.on_success { render json: {} }
    cmd.on_failure { |errors| render_400(:failed_validations, errors: errors) }
  end
end
```

**Key Benefits:**

- **Separation of concerns**: Controllers handle HTTP concerns, commands handle business logic
- **Testability**: Business logic can be tested independently of HTTP layer
- **Consistency**: Uniform error handling and response patterns
- **Reusability**: Commands can be called from multiple contexts (API, web, background jobs)

### Error Handling Patterns

#### Standard Error Responses

The API uses consistent error response formats:

```ruby
# 400 Bad Request - Validation errors
render_400(:failed_validations, errors: validation_errors)

# 403 Forbidden - Authorization errors
render_403(:track_not_joined)

# 404 Not Found - Resource not found
render_404(:solution_not_found)

# 422 Unprocessable Entity - Business logic violations
render_422(:exercise_locked)
```

#### Error Response Format

All errors follow a consistent JSON structure:

```json
{
  "error": {
    "type": "failed_validations",
    "message": "Human readable error message",
    "errors": {
      "field_name": ["specific validation error"]
    }
  }
}
```

### Response Patterns

#### Success Responses

- **Create operations**: Return 201 with created resource
- **Update operations**: Return 200 with updated data or empty JSON `{}`
- **Delete operations**: Return 200 with confirmation or empty JSON `{}`
- **Query operations**: Return 200 with requested data

#### Pagination

For endpoints returning collections:

```json
{
  "results": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 95
  }
}
```

## Controller Base Classes

### API::BaseController

Provides common functionality for all API controllers:

```ruby
class API::BaseController < ApplicationController
  # Authentication enforcement
  before_action :authenticate_user!

  # Error handling helpers
  def render_400(type, errors: nil)
  def render_403(type, message: nil)
  def render_404(type, message: nil)
  def render_422(type, message: nil)

  # Current user helper
  def current_user
end
```

### Authentication Guards

Use the `guard_incorrect_token!` helper in tests to verify authentication:

```ruby
class API::SolutionsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_solutions_path
  guard_incorrect_token! :update_api_solution_path, args: 1, method: :patch
end
```

## Route Organization

Routes are organized in `config/routes/api.rb` with logical groupings:

```ruby
namespace :api do
  # User management
  resources :users, only: %i[show update]

  # Track and exercise progression
  resources :tracks do
    member do
      patch :activate_practice_mode
      patch :activate_learning_mode
      patch :reset
    end
  end

  # Solution management
  resources :solutions do
    resources :submissions, only: %i[create show]
    resources :iterations, only: %i[index show]
  end
end
```

## Testing Patterns

### Controller Tests

API controller tests focus on HTTP concerns and command integration:

```ruby
class API::SolutionsControllerTest < API::BaseTestCase
  test 'create calls Solution::Create command' do
    setup_user
    exercise = create :exercise

    Solution::Create.expects(:call).with(@current_user, exercise).returns(
      mock_solution
    )

    post api_solutions_path,
         params: { exercise_id: exercise.id }, headers: @headers, as: :json

    assert_response :created
  end
end
```

### Authentication Testing

Always test authentication boundaries:

```ruby
test 'requires authentication' do
  post api_solutions_path, as: :json
  assert_response :unauthorized
end
```

### Command Integration Testing

Test that controllers properly handle command failures:

```ruby
test 'handles validation errors' do
  setup_user
  failing_command = mock('command')
  failing_command.expects(:on_success)
  failing_command.expects(:on_failure).yields(["Name can't be blank"])

  User::Update.expects(:call).returns(failing_command)

  patch api_user_path, params: { name: '' }, headers: @headers, as: :json

  assert_response :bad_request
  assert_includes response.parsed_body['error']['errors']['name'],
                  "Name can't be blank"
end
```

## Performance Considerations

### Caching Strategy

- Use Rails fragment caching for expensive computations
- Implement ETags for conditional requests where appropriate
- Cache command results when commands are idempotent

### Rate Limiting

Consider implementing rate limiting for:

- User registration endpoints
- File upload endpoints
- Expensive computation endpoints

### Serialization

Use consistent serialization patterns:

- Delegate to command objects when possible
- Use `SerializeExercise`, `SerializeSolution` helpers
- Include only necessary data to minimize payload size

## Security Considerations

### Input Validation

- All input validation happens in command objects, not controllers
- Controllers only handle HTTP-specific concerns
- Use strong parameters for basic input filtering

### Authorization

- Authentication happens at the controller level
- Authorization logic belongs in command objects
- Use consistent authorization patterns across commands

### CORS and CSP

- API endpoints support CORS for legitimate frontend usage
- Content Security Policy headers protect against XSS
- Validate all file uploads and user-generated content
