require_relative './base_test_case'

module API
  class ExportSolutionsControllerTest < API::BaseTestCase
    guard_incorrect_token! :api_track_exercise_export_solutions_path, args: 2, method: :get

    #########
    # INDEX #
    #########
    test "index should return export zip file" do
      user = create :user, :maintainer
      setup_user(user)

      track = create :track
      exercise = create(:practice_exercise, track:)

      get api_track_exercise_export_solutions_path(track.slug, exercise.slug), headers: @headers, as: :json

      assert_response :ok
      assert Zip::File.open_buffer(response.body) # Verify that the response is a zip file
    end

    test "index renders 404 when track not found" do
      user = create :user, :maintainer
      setup_user(user)

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
      user = create :user, :maintainer
      setup_user(user)

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

    test "index renders 403 when user is not a maintainer or admin" do
      user = create :user, roles: []
      setup_user(user)

      track = create :track
      exercise = create(:practice_exercise, track:)

      get api_track_exercise_export_solutions_path(track.slug, exercise.slug), headers: @headers, as: :json

      assert_response :forbidden
      assert_equal(
        {
          "error" => {
            "type" => "not_maintainer",
            "message" => "You do not have maintainer permissions"
          }
        },
        JSON.parse(response.body)
      )
    end

    %i[admin maintainer].each do |role|
      test "index should export when requested by #{role}" do
        user = create :user, role
        setup_user(user)

        track = create :track
        exercise = create(:practice_exercise, track:)

        get api_track_exercise_export_solutions_path(track.slug, exercise.slug), headers: @headers, as: :json

        assert_response :ok
      end
    end

    test "index is rate limited" do
      user = create :user, :maintainer
      setup_user(user)

      track = create :track
      exercise = create(:practice_exercise, track:)

      beginning_of_week = Time.current.beginning_of_week
      travel_to beginning_of_week

      10.times do |_idx|
        get api_track_exercise_export_solutions_path(track.slug, exercise.slug), headers: @headers, as: :json

        assert_response :success
      end

      get api_track_exercise_export_solutions_path(track.slug, exercise.slug), headers: @headers, as: :json

      assert_response :too_many_requests

      # Verify that the rate limit resets every week
      travel_to beginning_of_week + 1.week

      get api_track_exercise_export_solutions_path(track.slug, exercise.slug), headers: @headers, as: :json

      assert_response :success
    end
  end
end
