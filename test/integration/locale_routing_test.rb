require "test_helper"

class LocaleRoutingTest < ActionDispatch::IntegrationTest
  test "english is served naked" do
    get tracks_path
    assert_response :ok
  end

  test "a locale this environment doesn't serve is a 404" do
    get "/hu/tracks"
    assert_response :not_found
  end

  test "a query param is not a locale" do
    get "/tracks?locale=hu"
    assert_response :ok

    get "/tracks?locale=nonsense"
    assert_response :ok
  end

  test "a work in progress locale is hidden from the public" do
    with_served_locales(:hu) do
      get "/hu/tracks"
      assert_response :not_found

      sign_in!(create(:user))
      get "/hu/tracks"
      assert_response :not_found
    end
  end

  test "a work in progress locale is visible to staff and its translators" do
    with_served_locales(:hu) do
      sign_in!(create(:user, :staff))
      get "/hu/tracks"
      assert_response :ok

      sign_in!(create(:user).tap { |u| u.update!(translator_locales: ["hu"]) })
      get "/hu/tracks"
      assert_response :ok

      sign_in!(create(:user).tap { |u| u.update!(translator_locales: ["nl"]) })
      get "/hu/tracks"
      assert_response :not_found
    end
  end

  test "a production locale is visible to everyone" do
    with_served_locales(:hu) do
      LocaleRoster.stubs(production: %i[en hu])

      get "/hu/tracks"
      assert_response :ok
    end
  end

  test "links on a localised page stay in that locale" do
    with_served_locales(:hu) do
      LocaleRoster.stubs(production: %i[en hu])

      get "/hu/tracks"
      assert_includes response.body, %(href="/hu/tracks)
    end
  end

  test "a signed-out visitor gets english on a naked url" do
    get "/tracks"

    assert_response :ok
    assert_select "html[lang='en-US']"
  end

  test "a signed-in user's own locale is rendered on a naked url, with no redirect" do
    with_served_locales(:hu) do
      user = create :user, :staff
      user.update!(locale: "hu")
      sign_in!(user)

      get "/tracks"

      assert_response :ok
      assert_select "html[lang=hu]"
      assert_select "meta[name=exercism-locale][content=hu]"
      assert_equal "private, no-store", response.headers["Cache-Control"]

      get "/hu/tracks"
      refute_equal "private, no-store", response.headers["Cache-Control"]
    end
  end

  test "the url wins over the user's locale" do
    with_served_locales(:hu, :nl) do
      user = create :user, :staff
      user.update!(locale: "nl")
      sign_in!(user)

      get "/hu/tracks"

      assert_response :ok
      assert_select "html[lang=hu]"
    end
  end

  test "english, unknown and unviewable user locales fall back to english" do
    with_served_locales(:hu) do
      user = create :user
      sign_in!(user)

      ["en", "en-GB", "xx", "hu", nil].each do |locale|
        user.update!(locale:)
        get "/tracks"

        assert_response :ok
        assert_select "html[lang='en-US']"
        refute_equal "private, no-store", response.headers["Cache-Control"]
      end
    end
  end
end
