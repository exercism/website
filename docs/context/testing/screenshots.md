# Screenshots and Visual Testing

Screenshots are essential for visual debugging, theme testing, and documenting UI changes. Exercism has built-in screenshot capabilities through Capybara and system tests.

## Automatic Screenshot Generation

Screenshots are automatically saved when system tests fail to help with debugging:

- **Location**: `tmp/screenshots/`
- **Naming**: `failures_test_[test_method_name].png`
- **Resolution**: 1400x1000 pixels (configured in ApplicationSystemTestCase)

## Manual Screenshot Generation

### In System Tests

```ruby
class ThemeVisualTest < ApplicationSystemTestCase
  test 'matrix theme appears correctly' do
    user = create :user
    sign_in!(user)

    # Switch to matrix theme
    visit edit_settings_preferences_path
    click_button 'Matrix'

    # Take screenshot of dashboard
    visit dashboard_path
    page.save_screenshot('tmp/screenshots/matrix_theme_dashboard.png')

    # Take screenshot of exercise page
    track = create :track
    exercise = create :practice_exercise, track: track
    visit track_exercise_path(track, exercise)
    page.save_screenshot('tmp/screenshots/matrix_theme_exercise.png')
  end
end
```

### Manual Testing Commands

```bash
# Run specific visual test
bundle exec rails test test/system/flows/theme_visual_test.rb

# Run all system tests (generates screenshots on failures)
bundle exec rails test:system

# Run specific test with verbose output
bundle exec rails test test/system/flows/theme_visual_test.rb -v
```

## Screenshot Analysis with AI

AI agents can analyze screenshots to:

- **Verify theme colors**: Check if green-on-black Matrix theme is applied correctly
- **Detect visual regressions**: Compare before/after screenshots
- **Validate responsive design**: Ensure layouts work at different screen sizes
- **Debug styling issues**: Identify CSS problems visually

### Example AI Analysis Workflow

1. **Generate screenshots**:

   ```bash
   bundle exec rails test test/system/flows/theme_visual_test.rb
   ```

2. **AI reads and analyzes**:

   ```ruby
   # AI can read the screenshot file and provide visual analysis
   Read(
     '/Users/iHiD/Code/exercism/website/tmp/screenshots/matrix_theme_dashboard.png'
   )
   ```

3. **AI feedback**:
   - "Matrix theme correctly applied - background is black, text is green"
   - "Navigation bar maintains readability with new color scheme"
   - "Issue detected: button hover states not visible in Matrix theme"

## Best Practices

### Screenshot Organization

```ruby
# Use descriptive names
page.save_screenshot('tmp/screenshots/matrix_theme_settings_page.png')
page.save_screenshot('tmp/screenshots/before_theme_change.png')
page.save_screenshot('tmp/screenshots/after_matrix_theme_applied.png')

# Include viewport size for responsive testing
page.save_screenshot('tmp/screenshots/matrix_theme_mobile_dashboard.png')
```

### Theme Testing Strategy

1. **Baseline Screenshots**: Capture existing themes first
2. **New Theme Screenshots**: Generate Matrix theme versions
3. **Comparison Analysis**: Use AI to identify differences
4. **Edge Case Testing**: Test modals, dropdowns, form states

### System Test Helpers

```ruby
module ScreenshotHelpers
  def take_theme_screenshot(theme_name, page_name)
    filename = "tmp/screenshots/#{theme_name}_#{page_name}_#{timestamp}.png"
    page.save_screenshot(filename)
    filename
  end

  def switch_theme(theme_value)
    visit edit_settings_preferences_path
    click_button theme_value.humanize
    wait_for { page.has_css?(".theme-#{theme_value}") }
  end

  private

  def timestamp
    Time.current.strftime('%Y%m%d_%H%M%S')
  end
end
```

## Technical Details

- **Browser**: Chrome headless with 1400x1000 resolution
- **Driver**: Selenium WebDriver with Chrome options
- **Storage**: Local `tmp/screenshots/` directory
- **Format**: PNG files
- **No MCP required**: Direct command execution through Bash tool
- **AI Vision**: Full image analysis capabilities through Read tool

## Common Use Cases

### Theme Development

```ruby
test 'all themes render correctly on dashboard' do
  user = create :user
  sign_in!(user)

  %w[light dark system sepia accessibility-dark matrix].each do |theme|
    switch_theme(theme)
    visit dashboard_path
    page.save_screenshot("tmp/screenshots/#{theme}_dashboard.png")
  end
end
```

### Component Visual Testing

```ruby
test 'exercise widget displays correctly in matrix theme' do
  # Setup data
  track = create :track
  exercise = create :practice_exercise, track: track
  user = create :user
  sign_in!(user)

  # Switch to Matrix theme
  switch_theme('matrix')

  # Test different exercise states
  visit track_exercise_path(track, exercise)
  page.save_screenshot('tmp/screenshots/matrix_exercise_widget_locked.png')

  # Join track and take another screenshot
  click_button 'Join Track'
  page.save_screenshot('tmp/screenshots/matrix_exercise_widget_available.png')
end
```

## Ad-Hoc Screenshot Generation

For quick visual verification without cluttering the regular test suite, use the visual test system:

### Usage

```bash
# Run specific visual test
bundle exec rake screenshot:generate[tracks_page_test]

# Run all visual tests
bundle exec rake screenshot:generate

# List available visual tests
ls test/visual/*_test.rb
```

### Creating Visual Tests

Create tests in `test/visual/` directory - they won't run with `bundle exec rails test:system`:

```ruby
# test/visual/matrix_theme_test.rb
require 'application_system_test_case'

class MatrixThemeVisualTest < ApplicationSystemTestCase
  test 'matrix theme dashboard' do
    user = create :user, theme: 'matrix'
    sign_in!(user)

    visit dashboard_path
    page.save_screenshot('tmp/screenshots/matrix_dashboard.png')
    puts '✅ Matrix dashboard screenshot saved'
  end
end
```

### Key Features

- **Isolated**: Visual tests don't interfere with regular test suite
- **No CI impact**: Won't run on continuous integration
- **Easy data setup**: Create test data as needed per screenshot
- **Theme testing**: Built-in helpers for testing different themes
- **Custom runner**: Uses `rake screenshot:generate` instead of minitest

This documentation enables comprehensive visual testing without requiring any additional MCP tools or special setup.
