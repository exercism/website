# System Tests

System tests verify end-to-end user workflows using browser automation. They should:
- **Test complete user journeys**: From login to task completion
- **Verify UI interactions**: Button clicks, form submissions, navigation
- **Check visual feedback**: Success messages, error states, loading indicators
- **Use realistic test data**: Mirror production scenarios

## Example

```ruby
class UserRegistrationTest < ApplicationSystemTestCase
  test "user registers successfully" do
    visit new_user_registration_path
    fill_in "Email", with: "user@exercism.org"
    fill_in "Username", with: "user22"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"

    click_on "Sign Up", class: "test-sign-up-btn"

    assert_text "Check your email"
  end

  test "user sees validation errors" do
    visit new_user_registration_path
    fill_in "Email", with: "invalid-email"
    click_on "Sign Up"

    assert_text "Email is invalid"
  end
end
```

## Available Helper Methods (ApplicationSystemTestCase)

- `sign_in!(user = nil)`: Creates and signs in user, confirms account, sets `@current_user`
- `assert_page(page)`: Verifies current page by checking for `#page-{page}` element
- `assert_html(html, within: "body")`: Compares HTML structure within specified element
- `assert_text(text, **options)`: Enhanced text assertion with normalized whitespace
- `assert_no_text(text, **options)`: Text absence assertion with React loading delay handling
- `url_to_path(url)`: Converts full URL to path for route comparisons
- `expecting_errors { ... }`: Disables JavaScript error checking for tests that expect errors

## Capybara Integration

- Access to all Capybara helpers: `visit`, `fill_in`, `click_on`, `find`, etc.
- WebSocket testing support through `WebsocketsHelpers` module
- Custom browser configuration for headless Chrome with download directory setup
- Automatic JavaScript error detection and test failure on unexpected errors

## System Test Guidelines

- Use descriptive test names that explain the user action
- Include both success and failure scenarios  
- Use `wait` parameters for dynamic content loading
- Test accessibility and responsive behavior when relevant
- Use data attributes like `class: "test-sign-up-btn"` for reliable element selection