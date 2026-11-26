require "test_helper"

class Admin::MaintainingRedirectsTest < ActionDispatch::IntegrationTest
  test "the old maintaining root redirects to the admin section" do
    get "/maintaining"

    assert_response :moved_permanently
    assert_redirected_to "/admin"
  end

  test "an old maintaining page redirects to the same page in the admin section" do
    get "/maintaining/site_updates/new?track_slug=ruby"

    assert_response :moved_permanently
    assert_redirected_to "/admin/site_updates/new?track_slug=ruby"
  end

  test "a localized maintaining page redirects to the admin section" do
    locale = (I18n.available_locales - [I18n.default_locale]).first
    skip "No other locales are served" unless locale

    get "/#{locale}/maintaining/track_categories"

    assert_response :moved_permanently
    assert_redirected_to "/admin/track_categories"
  end
end
