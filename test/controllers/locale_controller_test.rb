require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  QUERY_PARAM   = LocaleRouting::QUERY_PARAM
  GOOGLEBOT_UA  = "Googlebot/2.1 (+http://www.google.com/bot.html)".freeze

  setup do
    @track = create(:track, slug: :ruby)
    @naked_path = track_path(:ruby)                  # /tracks/ruby
    @hu_path    = track_path(:ruby, locale: "hu")    # /hu/tracks/ruby
  end

  test "naked path renders with default locale" do
    get @naked_path
    assert_response :ok
  end

  test "naked path GET redirects based on Accept-Language" do
    get @naked_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "hu" }
    assert_redirected_to "#{@hu_path}?#{QUERY_PARAM}=1"
    assert_equal "no-store", response.headers["Cache-Control"]
  end

  test "naked path GET does not redirect if Accept-Language is default" do
    get @naked_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "en" }
    assert_response :ok
  end

  test "does not redirect if locale already in path" do
    get @hu_path
    assert_response :ok
  end

  test "does not redirect if logged-in user prefers default locale" do
    user = create(:user, locale: I18n.default_locale)
    sign_in!(user)
    get @naked_path
    assert_response :ok
  end

  test "redirects to logged-in user's saved non-default locale" do
    user = create(:user, locale: :hu)
    sign_in!(user)
    get @naked_path
    assert_redirected_to "#{@hu_path}?#{QUERY_PARAM}=1"
  end

  test "does not redirect bots" do
    get @naked_path, headers: { "User-Agent" => GOOGLEBOT_UA }
    assert_response :ok
  end

  test "loop-breaker param skips redirect even if Accept-Language would trigger" do
    get "#{@naked_path}?#{QUERY_PARAM}=1", headers: { "HTTP_ACCEPT_LANGUAGE" => "hu" }
    assert_response :ok
  end

  test "does not redirect non-GET requests for logged-in user" do
    user = create(:user, locale: :hu)
    sign_in!(user)

    post "#{@hu_path}/join", headers: { "HTTP_ACCEPT_LANGUAGE" => "fr" }

    # Should not include the locale loop-breaker param from our concern
    refute_includes response.location.to_s, "?#{QUERY_PARAM}="
  end

  test "does not redirect if already on a different non-default locale path than user preference" do
    user = create(:user, locale: :fr)
    sign_in!(user)
    track_path(:ruby, locale: "fr")
    get @hu_path
    assert_response :ok
  end

  test "redirect preserves path and query parameters" do
    get "#{@naked_path}?page=2", headers: { "HTTP_ACCEPT_LANGUAGE" => "hu" }
    assert_redirected_to "#{@hu_path}?page=2&#{QUERY_PARAM}=1"
  end

  test "logged-in user with non-default locale does not redirect if already on matching locale path" do
    user = create(:user, locale: :hu)
    sign_in!(user)
    get @hu_path
    assert_response :ok
  end

  test "logged-in user preference overrides Accept-Language for naked URLs" do
    I18n.available_locales = %i[en hu fr]

    user = create(:user, locale: :fr)
    sign_in!(user)
    get @naked_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "hu" }
    fr_path = track_path(:ruby, locale: "fr")
    assert_redirected_to "#{fr_path}?#{QUERY_PARAM}=1"
  end

  test "bot skips redirect even if Accept-Language would normally trigger" do
    get @naked_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "hu", "User-Agent" => GOOGLEBOT_UA }
    assert_response :ok
  end

  test "logged-in user with nil locale falls back to Accept-Language (redirects)" do
    user = create(:user, locale: nil)
    sign_in!(user)
    get @naked_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "hu" }
    assert_redirected_to "#{@hu_path}?#{QUERY_PARAM}=1"
  end

  test "logged-in user with nil locale and default Accept-Language does not redirect" do
    user = create(:user, locale: nil)
    sign_in!(user)
    get @naked_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "en" }
    assert_response :ok
  end
end
