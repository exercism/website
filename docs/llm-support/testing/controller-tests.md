# Controller Tests

Controller tests verify HTTP request handling and integration with command objects. They focus on authentication, parameter validation, and response formatting.

## API Controller Tests

- Inherit from `API::BaseTestCase` which provides authentication helpers
- Use `setup_user` to create authenticated test user with auth token
- Test authentication guards with `guard_incorrect_token!` class method
- Mock command objects to isolate controller logic from business logic

### Example

```ruby
class API::SolutionsControllerTest < API::BaseTestCase
  # Test authentication requirements for all endpoints
  guard_incorrect_token! :api_solutions_path
  guard_incorrect_token! :api_solution_path, args: 1, method: :patch

  test "create solution successfully" do
    setup_user
    exercise = create :exercise
    mock_solution = mock('solution')
    
    Solution::Create.expects(:call).with(@current_user, exercise).returns(mock_solution)
    
    post api_solutions_path, 
         params: { exercise_id: exercise.id },
         headers: @headers,
         as: :json
    
    assert_response :created
  end
end
```

### Available Helper Methods (API::BaseTestCase)

- `setup_user(user = nil)`: Creates authenticated user with auth token, sets `@current_user` and `@headers`
- `guard_incorrect_token!(path, args: 0, method: :get)`: Class method that generates authentication test
- `assert_json_response(expected)`: Compares JSON response with expected hash

## Standard Controller Tests

- Inherit from `ActionDispatch::IntegrationTest` for web controllers
- Test user flows, form submissions, and page rendering
- Use Devise test helpers for authentication