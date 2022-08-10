require_relative '../base_test_case'

module API
  module Solutions
    class ExportControllerTest < API::BaseTestCase
      guard_incorrect_token! :api_track_exercise_export_solutions_path, args: 2, method: :get

      #########
      # INDEX #
      #########
      test "index should return export zip file" do
        setup_user

        track = create :track
        exercise = create :practice_exercise, track: track

        get api_track_exercise_export_solutions_path(track.slug, exercise.slug), headers: @headers, as: :json

        assert_response :ok
        assert Zip::File.open_buffer(response.body) # Verify that the response is a zip file
      end

      test "index renders 404 when track not found" do
        setup_user

        get api_track_exercise_export_solutions_path('unknown', 'leap'), headers: @headers, as: :json

        assert_response :not_found
        assert_equal(
          {
            "error" => {
              "type" => "track_not_found",
              "message" => "The track you specified does not exist"
            }
          },
          JSON.parse(response.body)
        )
      end

      test "index renders 404 when exercise not found" do
        setup_user
        track = create :track

        get api_track_exercise_export_solutions_path(track.slug, 'unknown'), headers: @headers, as: :json

        assert_response :not_found
        assert_equal(
          {
            "error" => {
              "type" => "exercise_not_found",
              "message" => "The exercise you specified could not be found"
            }
          },
          JSON.parse(response.body)
        )
      end
    end
  end
end
