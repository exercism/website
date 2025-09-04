require "application_system_test_case"

# Visual verification test for Matrix theme - not part of regular test suite
# Run with: bundle exec rake screenshot:generate[matrix_theme_test]
# rubocop:disable Lint/Debugger
class MatrixThemeVisualTest < ApplicationSystemTestCase
  test "matrix theme on tracks page" do
    # Create test tracks with realistic data
    create :track, :random_slug, title: "Ruby", blurb: "A dynamic programming language"
    create :track, :random_slug, title: "JavaScript", blurb: "The language of the web"
    create :track, :random_slug, title: "Python", blurb: "A powerful programming language"

    # Create a user and sign in to access theme settings
    user = create :user
    sign_in!(user)

    # Update user preferences to matrix theme
    user.preferences.update!(theme: 'matrix')

    # Visit tracks page
    visit tracks_path

    # Wait for theme to apply
    sleep 1

    # Check CSS variables
    background_color_a = page.evaluate_script("getComputedStyle(document.body).getPropertyValue('--backgroundColorA')")
    text_color_1 = page.evaluate_script("getComputedStyle(document.body).getPropertyValue('--textColor1')")

    puts "🔍 CSS Variables Check:"
    puts "   --backgroundColorA: #{background_color_a}"
    puts "   --textColor1: #{text_color_1}"

    # Take screenshot
    page.save_screenshot('tmp/screenshots/matrix_theme_tracks_page.png')

    puts "✅ Matrix theme screenshot saved: tmp/screenshots/matrix_theme_tracks_page.png"
    puts "   Page title: #{page.title}"
    puts "   Current URL: #{page.current_url}"
    puts "   Body classes: #{page.evaluate_script('document.body.className')}"
    puts "   Tracks visible: #{page.all('.track-card, [data-testid*=track]').count}"
  end

  test "compare all themes on tracks page" do
    # Create test data
    create :track, :random_slug, title: "Ruby", blurb: "A dynamic programming language"
    create :track, :random_slug, title: "JavaScript", blurb: "The language of the web"

    user = create :user
    sign_in!(user)

    # Test all themes including the new matrix theme
    %w[light dark system sepia accessibility-dark matrix].each do |theme|
      # Switch theme by updating user preferences
      user.preferences.update!(theme: theme)

      visit tracks_path

      # Wait for theme to apply
      sleep 0.5

      # Take screenshot
      page.save_screenshot("tmp/screenshots/themes_comparison_#{theme}_tracks.png")
      puts "✅ Screenshot saved: tmp/screenshots/themes_comparison_#{theme}_tracks.png"
    end

    puts "\n🎯 All theme screenshots captured for comparison!"
    puts "   Matrix theme should show green-on-black styling"
    puts "   Check that Matrix theme has:"
    puts "   - Pure black (#000000) background"
    puts "   - Bright matrix green (#00FF00) text and accents"
    puts "   - Dark green (#004400) secondary elements"
  end
end
# rubocop:enable Lint/Debugger
