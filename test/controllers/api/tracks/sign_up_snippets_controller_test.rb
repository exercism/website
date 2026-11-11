require_relative '../base_test_case'

module API
  module Tracks
    class SignUpSnippetsControllerTest < API::BaseTestCase
      test "returns the snippet and its highlight.js language" do
        track = create :track, slug: "go"
        Rails.cache.write(Track::RetrieveSignUpSnippet.cache_key(track), "package main")

        get api_track_sign_up_snippet_path(track_slug: "go"), as: :json

        assert_response :ok
        assert_equal({ "snippet" => "package main", "highlightjs_language" => track.highlightjs_language },
          response.parsed_body)
      end

      test "returns the snippet to a signed-in user who is not onboarded" do
        user = create :user, :not_onboarded, seniority: nil
        track = create :track, slug: "go"
        Rails.cache.write(Track::RetrieveSignUpSnippet.cache_key(track), "package main")

        sign_in!(user)
        get api_track_sign_up_snippet_path(track_slug: "go"), as: :json

        assert_response :ok
        assert_equal "package main", response.parsed_body["snippet"]
      end

      test "returns 404 for a track without a snippet" do
        create :track, slug: "go"
        Track.any_instance.stubs(:sign_up_snippet).returns("")

        get api_track_sign_up_snippet_path(track_slug: "go"), as: :json

        assert_response :not_found
        assert_equal "track_not_found", response.parsed_body["error"]["type"]
      end

      test "returns 404 for an unknown or inactive track" do
        create :track, slug: "elm", active: false

        get api_track_sign_up_snippet_path(track_slug: "nope"), as: :json
        assert_response :not_found

        get api_track_sign_up_snippet_path(track_slug: "elm"), as: :json
        assert_response :not_found
      end

      test "is publicly cacheable and sets no cookies" do
        track = create :track, slug: "go"
        Rails.cache.write(Track::RetrieveSignUpSnippet.cache_key(track), "package main")

        get api_track_sign_up_snippet_path(track_slug: "go"), as: :json

        cache_control = response.headers["Cache-Control"]
        assert_includes cache_control, "public"
        assert_includes cache_control, "max-age=3600"
        assert_includes cache_control, "s-maxage=3600"
        assert_nil response.headers["Set-Cookie"]
      end
    end
  end
end
