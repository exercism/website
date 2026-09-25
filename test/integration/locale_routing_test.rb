require "test_helper"

class LocaleRoutingTest < ActionDispatch::IntegrationTest
  test "english is served naked" do
    get tracks_path
    assert_response :ok
  end

  test "a locale that is not served has no route" do
    assert_raises(ActionController::RoutingError) { get "/nl/tracks" }
  end

  test "a query param is not a locale" do
    get "/tracks?locale=hu"
    assert_response :ok

    get "/tracks?locale=nonsense"
    assert_response :ok
  end

  test "a served locale is visible to everyone" do
    get "/hu/tracks"
    assert_response :ok
  end

  test "links on a localised page stay in that locale" do
    get "/hu/tracks"
    assert_includes response.body, %(href="/hu/tracks)
  end

  test "a signed-out visitor gets english on a naked url" do
    get "/tracks"

    assert_response :ok
    assert_select "html[lang='en-US']"
  end

  test "a signed-in user's own locale is rendered on a naked url, with no redirect" do
    user = create :user
    user.update!(locale: "hu")
    sign_in!(user)

    get "/tracks"

    assert_response :ok
    assert_select "html[lang=hu]"
    assert_select "meta[name=exercism-locale][content=hu]"
    assert_equal "private, no-store", response.headers["Cache-Control"]
  end

  test "a signed-in user's links are never prefixed" do
    user = create :user
    user.update!(locale: "hu")
    sign_in!(user)

    get "/tracks"

    assert_includes response.body, %(href="/tracks)
    refute_includes response.body, %(href="/hu/)
  end

  test "a signed-in user is moved off a prefixed url" do
    user = create :user
    user.update!(locale: "hu")
    sign_in!(user)

    get "/hu/tracks?foo=bar"

    assert_redirected_to "/tracks?foo=bar"
    assert_response :found
    assert_equal "private, no-store", response.headers["Cache-Control"]
  end

  test "a signed-in user is moved off a prefixed url whatever their locale" do
    user = create :user
    sign_in!(user)

    get "/hu/tracks"

    assert_redirected_to "/tracks"
  end

  test "a signed-in user's own locale wins over the url when they are not moved" do
    with_available_locales(:hu, :nl) do
      user = create :user
      user.update!(locale: "nl")
      sign_in!(user)

      get "/hu/tracks", xhr: true

      assert_response :ok
      assert_select "meta[name=exercism-locale][content=nl]"
    end
  end

  test "a non-navigation request to a prefixed url is not moved" do
    user = create :user
    sign_in!(user)

    get "/hu/tracks", headers: { "Turbo-Frame" => "frame" }
    assert_response :ok

    get "/hu/tracks", as: :json
    refute_equal 302, response.status
  end

  test "english and unknown user locales fall back to english" do
    user = create :user
    sign_in!(user)

    ["en", "en-GB", "xx", nil].each do |locale|
      user.update!(locale:)
      get "/tracks"

      assert_response :ok
      assert_select "html[lang='en-US']"
      refute_equal "private, no-store", response.headers["Cache-Control"]
    end
  end
end
