require "test_helper"

class SettingsControllerUpdateLocaleTest < ActionDispatch::IntegrationTest
  # A signed-in user's locale is read off their account, so the switch has to
  # persist before the redirect lands on the new locale's URL.
  test "saves the chosen locale on the account" do
    user = create :user
    sign_in!(user)

    patch update_locale_settings_path, params: { new_locale: "hu", return_to: "/tracks" }

    assert_equal "hu", user.reload.locale
    assert_redirected_to "/hu/tracks"
  end

  test "records the preference cookie, so the choice survives signing out" do
    sign_in!

    patch update_locale_settings_path, params: { new_locale: "hu", return_to: "/tracks" }

    assert_equal "hu", cookies[Locale::PREF_COOKIE_NAME.to_s]
  end

  test "drops the locale prefix when switching back to the default locale" do
    user = create :user, locale: "hu"
    sign_in!(user)

    patch update_locale_settings_path, params: { new_locale: "en", return_to: "/hu/tracks" }

    assert_equal "en", user.reload.locale
    assert_redirected_to "/tracks"
  end

  test "ignores a locale we do not serve" do
    user = create :user, locale: "hu"
    sign_in!(user)

    patch update_locale_settings_path, params: { new_locale: "de", return_to: "/tracks" }

    assert_equal "hu", user.reload.locale
  end

  # return_to is user input, so it may only ever be a path on this site.
  test "refuses an off-site return path" do
    sign_in!

    patch update_locale_settings_path, params: { new_locale: "hu", return_to: "https://evil.test/x" }

    assert_redirected_to "/hu"
  end

  test "refuses a protocol-relative return path" do
    sign_in!

    patch update_locale_settings_path, params: { new_locale: "hu", return_to: "//evil.test/x" }

    assert_redirected_to "/hu"
  end

  test "switches away from a prefixed page, rather than back to its prefix" do
    user = create :user, locale: "hu"
    sign_in!(user)

    patch "/hu/settings/update_locale", params: { new_locale: "en", return_to: "/hu/tracks" }

    assert_equal "en", user.reload.locale
    assert_redirected_to "/tracks"
  end

  test "switches between two non-default locales from a prefixed page" do
    user = create :user, locale: "en"
    sign_in!(user)

    patch "/hu/settings/update_locale", params: { new_locale: "hu", return_to: "/hu/tracks" }

    assert_equal "hu", user.reload.locale
    assert_redirected_to "/hu/tracks"
  end

  test "ignores a missing locale rather than erroring" do
    user = create :user, locale: "hu"
    sign_in!(user)

    patch update_locale_settings_path, params: { return_to: "/tracks" }

    assert_equal "hu", user.reload.locale
    assert_response :redirect
  end

  test "requires a signed-in user" do
    patch update_locale_settings_path, params: { new_locale: "hu", return_to: "/tracks" }

    assert_redirected_to new_user_session_path
  end
end
