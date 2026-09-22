require "test_helper"

class LocaleRoutesTest < ActionDispatch::IntegrationTest
  test "website routes are served naked and under a locale" do
    assert_recognizes({ controller: "tracks", action: "index" }, "/tracks")
    assert_recognizes({ controller: "tracks", action: "index", locale: "hu" }, "/hu/tracks")
    assert_recognizes({ controller: "pages", action: "index", locale: "hu" }, "/hu")
    assert_recognizes({ controller: "auth/sessions", action: "new", locale: "hu" }, "/hu/users/sign_in")
  end

  test "a segment that is not a known locale is not a locale" do
    assert_raises(ActionController::RoutingError) { Rails.application.routes.recognize_path("/xx/tracks") }
    assert_raises(ActionController::RoutingError) { Rails.application.routes.recognize_path("/hungary/tracks") }
  end

  test "routes that must never be locale-scoped" do
    [
      [:get, "/hu/users/auth/github/callback"],
      [:post, "/hu/webhooks/stripe"],
      [:post, "/hu/webhooks/push_updates"],
      [:get, "/hu/discourse/sso"],
      [:get, "/hu/admin"],
      [:get, "/hu/moderation/shadow_banned_users"],
      [:get, "/hu/challenges/48in24"],
      [:get, "/hu/bootcamp"],
      [:get, "/hu/courses"],
      [:get, "/hu/api/v2/tracks"],
      [:get, "/hu/spi/solution_image_data/ruby/bob/ihid"],
      [:get, "/hu/sitemap"],
      [:get, "/hu/robots"],
      [:get, "/hu/health-check"],
      [:get, "/hu/site.webmanifest"],
      [:get, "/hu/avatars/1/2"],
      [:get, "/hu/test-runners/jq/latest.json"],
      [:get, "/hu/perks/1/claim"],
      [:get, "/hu/oauth/authorize"],
      [:get, "/hu/404"]
    ].each do |method, path|
      assert_raises(ActionController::RoutingError, "#{path} should not be routable") do
        Rails.application.routes.recognize_path(path, method:)
      end
    end
  end

  test "generated urls carry the ambient locale" do
    track = create :track, slug: "ruby"

    assert_equal "/tracks/ruby", Exercism::Routes.track_path(track)
    assert_equal "https://test.exercism.org/tracks", Exercism::Routes.tracks_url

    I18n.with_locale(:hu) do
      assert_equal "/hu", Exercism::Routes.root_path
      assert_equal "/hu/tracks/ruby", Exercism::Routes.track_path(track)
      assert_equal "https://test.exercism.org/hu/tracks", Exercism::Routes.tracks_url
      assert_equal "/hu/tracks/ruby/exercises/bob", Exercism::Routes.track_exercise_path(track, "bob")
      assert_equal "/challenges/48in24", Exercism::Routes.challenge_path("48in24")
    end
  end

  test "an explicit locale beats the ambient one" do
    assert_equal "/hu/tracks", Exercism::Routes.tracks_path(locale: :hu)
    I18n.with_locale(:hu) do
      assert_equal "/tracks", Exercism::Routes.tracks_path(locale: nil)
    end
  end

  test "/en redirects to the naked url" do
    get "/en/tracks?criteria=ruby"
    assert_redirected_to "/tracks?criteria=ruby"
    assert_equal 301, response.status

    get "/en"
    assert_redirected_to "/"
  end
end
