require_relative '../base_test_case'

module API
  module Exercises
    class ScratchpadPageControllerTest < API::BaseTestCase
      ###
      # CREATE
      ###
      test "create should return 401 with incorrect token" do
        post api_track_exercise_scratchpad_page_path("ruby", "bad_exercise"), as: :json

        assert_response 401
        expected = { error: {
          type: "invalid_auth_token",
          message: I18n.t("api.errors.invalid_auth_token")
        } }
        actual = JSON.parse(response.body, symbolize_names: true)
        assert_equal expected, actual
      end

      test "create should return 404 with track not found" do
        setup_user
        post api_track_exercise_scratchpad_page_path("ruby", "exercise"),
          headers: @headers,
          as: :json

        assert_response 404
        expected = { error: {
          type: "track_not_found",
          message: I18n.t("api.errors.track_not_found"),
          fallback_url: tracks_url
        } }
        actual = JSON.parse(response.body, symbolize_names: true)
        assert_equal expected, actual
      end

      test "create should return 404 with exercise not found" do
        setup_user
        track = create(:track)
        post api_track_exercise_scratchpad_page_path(track, "exercise"),
          headers: @headers,
          as: :json

        assert_response 404
        expected = { error: {
          type: "exercise_not_found",
          message: I18n.t("api.errors.exercise_not_found"),
          fallback_url: track_url(track)
        } }
        actual = JSON.parse(response.body, symbolize_names: true)
        assert_equal expected, actual
      end

      test "create should save scratchpad page" do
        setup_user
        exercise = create :concept_exercise

        post api_track_exercise_scratchpad_page_path(exercise.track, exercise),
          headers: @headers,
          params: { content_markdown: "Some notes" },
          as: :json

        assert_response :success
        expected = {
          scratchpad_page: {
            id: ScratchpadPage.last.id,
            about_type: "Exercise",
            about_id: exercise.id,
            user_id: @current_user.id,
            content_markdown: "Some notes"
          }
        }
        actual = JSON.parse(response.body, symbolize_names: true)
        assert_equal expected, actual
      end
    end
  end
end
