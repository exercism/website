require "test_helper"

class UrlDefaultsTest < ActiveSupport::TestCase
  test "english urls carry no locale" do
    assert_equal "/api/v2/tracks", Exercism::Routes.api_tracks_path
    assert_equal "/admin", Exercism::Routes.admin_root_path
  end

  test "routes that are not locale-scoped never leak the locale as a query param" do
    I18n.with_locale(:hu) do
      assert_equal "/api/v2/tracks", Exercism::Routes.api_tracks_path
      assert_equal "/admin", Exercism::Routes.admin_root_path
      assert_equal "/users/auth/github/callback", Exercism::Routes.user_github_omniauth_callback_path
      assert_equal "https://test.exercism.org/webhooks/stripe", Exercism::Routes.webhooks_stripe_url
    end
  end

  test "an explicit locale on an unscoped route is dropped too" do
    assert_equal "/api/v2/tracks", Exercism::Routes.api_tracks_path(locale: :hu)
  end

  test "other options still pass through" do
    I18n.with_locale(:hu) do
      assert_equal "/api/v2/tracks?criteria=ruby", Exercism::Routes.api_tracks_path(criteria: "ruby")
    end
  end
end
