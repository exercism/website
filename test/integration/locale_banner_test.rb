require "test_helper"

class LocaleBannerTest < ActionDispatch::IntegrationTest
  test "no banner for a visitor already on the language they chose" do
    cookies[Locale::PREF_COOKIE_NAME] = "en"
    get "/tracks", headers: { "Accept-Language" => "hu" }

    assert_response :ok
    refute_includes response.body, "data-locale-banner"
  end

  test "a hungarian-speaking visitor pinned to english is offered hungarian" do
    get "/hu/tracks", headers: { "Accept-Language" => "en-GB,en;q=0.9" }

    assert_response :ok
    assert_select "[data-locale-banner=en]"
    assert_select ".c-locale-banner a[href='/tracks']"
  end

  test "the banner makes the page uncacheable" do
    get "/hu/tracks", headers: { "Accept-Language" => "en" }

    assert_equal "private, no-store", response.headers["Cache-Control"]
    assert_includes response.headers["Vary"], "Accept-Language"
  end

  test "no banner when the page is already the offered language" do
    get "/hu/tracks", headers: { "Accept-Language" => "hu" }

    assert_response :ok
    refute_includes response.body, "data-locale-banner"
  end

  test "no banner for a client sending no accept-language" do
    get "/hu/tracks"

    assert_response :ok
    refute_includes response.body, "data-locale-banner"
  end

  test "a signed-in user is offered their account language" do
    user = create :user
    user.update!(locale: "hu")
    sign_in!(user)

    get "/tracks", headers: { "Accept-Language" => "en" }

    assert_response :ok
    refute_includes response.body, "data-locale-banner"
  end

  test "the switch link records the choice" do
    get "/hu/tracks", headers: { "Accept-Language" => "en" }

    assert_select ".c-locale-banner a[data-locale-pref=en]"
  end
end
