require "application_system_test_case"

# Visual verification test - not part of regular test suite
# Run with: bundle exec rake screenshot:generate[tracks_page_test]
# rubocop:disable Lint/Debugger
class TracksPageVisualTest < ApplicationSystemTestCase
  test "verify tracks page appearance" do
    # Create some test tracks with realistic data
    create :track, :random_slug, title: "Ruby", blurb: "A dynamic programming language"
    create :track, :random_slug, title: "JavaScript", blurb: "The language of the web"
    create :track, :random_slug, title: "Python", blurb: "A powerful programming language"

    visit tracks_path

    # Take screenshot
    page.save_screenshot('tmp/screenshots/visual_tracks_page.png')

    puts "✅ Screenshot saved: tmp/screenshots/visual_tracks_page.png"
    puts "   Page title: #{page.title}"
    puts "   Current URL: #{page.current_url}"
    puts "   Tracks visible: #{page.all('.track-card, [data-testid*=track]').count}"
  end

  test "verify tracks page with different themes" do
    # Create test data
    create :track, :random_slug, title: "Ruby", blurb: "A dynamic programming language"
    user = create :user
    sign_in!(user)

    # Test different themes
    %w[light dark system sepia accessibility-dark].each do |theme|
      # Switch theme by updating user preferences
      user.preferences.update!(theme: theme)

      visit tracks_path

      # Wait for theme to apply
      sleep 0.5

      # Take screenshot
      page.save_screenshot("tmp/screenshots/visual_tracks_#{theme}_theme.png")
      puts "✅ Screenshot saved: tmp/screenshots/visual_tracks_#{theme}_theme.png"
    end
  end
end
# rubocop:enable Lint/Debugger
