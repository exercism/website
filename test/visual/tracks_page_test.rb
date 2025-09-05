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

    # Verify i18n is working for tracks page title
    translation = Localization::Translation.find_by(locale: "en", key: "tracks.index.header.title")
    assert translation.present?, "Translation for tracks.index.header.title should exist"
    assert_includes translation.value, "%<num_tracks>s languages", "Translation should contain expected text"

    visit tracks_path

    # Verify the translation is actually rendered (should contain "3 languages" not "Title")
    assert_no_text "Title"
    assert_no_text "Description HTML"
    assert_text "3 languages for you to master"

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
