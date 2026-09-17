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

  test "signed-in users are not redirected while the decision is open" do
    with_served_locales(:hu) do
      user = create :user, :staff
      user.update!(locale: "hu")
      sign_in!(user)

      get "/tracks"
      assert_response :ok
    end
  end

  class RedirectTest < ActionDispatch::IntegrationTest
    setup do
      LocaleRouting.send(:remove_const, :REDIRECT_SIGNED_IN_USERS)
      LocaleRouting.const_set(:REDIRECT_SIGNED_IN_USERS, true)

      @user = create :user, :staff
      @user.update!(locale: "hu")
      sign_in!(@user)
    end

    teardown do
      LocaleRouting.send(:remove_const, :REDIRECT_SIGNED_IN_USERS)
      LocaleRouting.const_set(:REDIRECT_SIGNED_IN_USERS, false)
    end

    test "redirects a naked url to the user's locale, uncached, with no loop-breaker" do
      with_served_locales(:hu) do
        get "/tracks?criteria=ruby"

        assert_redirected_to "/hu/tracks?criteria=ruby"
        assert_equal 302, response.status
        assert_includes response.headers["Cache-Control"], "no-store"

        follow_redirect!
        assert_response :ok
      end
    end

    test "the url wins over the preference" do
      with_served_locales(:hu, :nl) do
        @user.update!(locale: "nl")

        get "/hu/tracks"
        assert_response :ok
      end
    end

    test "never redirects onto a route that has no localised version" do
      with_served_locales(:hu) do
        get "/moderation/shadow_banned_users"
        refute_includes response.location.to_s, "/hu/"

        get "/admin"
        refute_equal "/hu/admin", URI(response.location.to_s).path
      end
    end

    test "only html navigations redirect" do
      with_served_locales(:hu) do
        get "/api/v2/tracks", as: :json
        refute response.redirect?

        post "/tracks/ruby/join"
        refute_includes response.location.to_s, "/hu/tracks/ruby/join"
      end
    end

    test "english, unknown and unviewable preferences do nothing" do
      with_served_locales(:hu) do
        ["en", "en-GB", "xx", nil].each do |locale|
          @user.update!(locale:)
          get "/tracks"
          assert_response :ok
        end
      end

      # hu is not served here
      @user.update!(locale: "hu")
      get "/tracks"
      assert_response :ok
    end
  end
end
