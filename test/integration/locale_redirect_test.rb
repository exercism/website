require "test_helper"

class LocaleRedirectTest < ActionDispatch::IntegrationTest
  test "a first-time visitor is sent to their browser's language" do
    get "/tracks", headers: { "Accept-Language" => "hu,en;q=0.5" }

    assert_redirected_to "/hu/tracks"
    assert_equal 302, response.status
  end

  test "the redirect is never cached" do
    get "/tracks", headers: { "Accept-Language" => "hu" }

    assert_equal "private, no-store", response.headers["Cache-Control"]
    assert_includes response.headers["Vary"], "Accept-Language"
    assert_includes response.headers["Vary"], "Cookie"
  end

  test "the query string survives the redirect" do
    get "/tracks?page=2", headers: { "Accept-Language" => "hu" }

    assert_redirected_to "/hu/tracks?page=2"
  end

  test "the preference cookie beats the browser" do
    cookies[Locale::PREF_COOKIE_NAME] = "en"
    get "/hu/tracks", headers: { "Accept-Language" => "hu" }

    assert_redirected_to "/tracks"
  end

  test "the preference cookie beats the path" do
    cookies[Locale::PREF_COOKIE_NAME] = "hu"
    get "/tracks", headers: { "Accept-Language" => "en" }

    assert_redirected_to "/hu/tracks"
  end

  test "an unsupported preference cookie is ignored" do
    cookies[Locale::PREF_COOKIE_NAME] = "nonsense"
    get "/tracks", headers: { "Accept-Language" => "hu" }

    assert_redirected_to "/hu/tracks"
  end

  test "the path beats the browser" do
    get "/hu/tracks", headers: { "Accept-Language" => "en-GB,en;q=0.9" }

    assert_response :ok
  end

  test "no accept-language means no redirect" do
    get "/tracks"

    assert_response :ok
  end

  test "an unsupported accept-language means no redirect" do
    get "/tracks", headers: { "Accept-Language" => "nl,de;q=0.8" }

    assert_response :ok
  end

  test "a visitor already on their language is not redirected" do
    get "/hu/tracks", headers: { "Accept-Language" => "hu" }

    assert_response :ok
  end

  test "HEAD is redirected too" do
    head "/tracks", headers: { "Accept-Language" => "hu" }

    assert_redirected_to "/hu/tracks"
  end

  test "non-html is not redirected" do
    get "/tracks.json", headers: { "Accept-Language" => "hu" }

    refute_equal 302, response.status
  end

  test "turbo frame requests are not redirected" do
    get "/tracks", headers: { "Accept-Language" => "hu", "Turbo-Frame" => "tf-main" }

    assert_response :ok
  end

  test "signed-in users are never redirected" do
    user = create :user
    user.update!(locale: "hu")
    sign_in!(user)

    get "/tracks", headers: { "Accept-Language" => "hu" }

    assert_response :ok
  end

  test "auth flows are excluded" do
    get "/users/sign_in", headers: { "Accept-Language" => "hu" }

    assert_response :ok
  end

  test "settings is excluded" do
    get "/settings", headers: { "Accept-Language" => "hu" }

    assert_redirected_to "/users/sign_in"
  end

  test "api is excluded" do
    get "/api/tracks", headers: { "Accept-Language" => "hu" }

    refute_equal 302, response.status
  end

  test "public sections and pages participate" do
    %w[/ /tracks /docs /community].each do |path|
      get path, headers: { "Accept-Language" => "hu" }

      assert_equal 302, response.status, "expected #{path} to redirect"
    end
  end
end
