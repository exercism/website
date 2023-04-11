require_relative './base_test_case'

module API
  class ExercisesControllerTest < API::BaseTestCase
    #########
    # INDEX #
    #########
    test "index should proxy params" do
      track = create :track
      user_track = mock
      UserTrack.stubs(:for).with(@current_user, track).returns(user_track)

      Exercise::Search.expects(:call).with(
        user_track,
        criteria: "ru"
      ).returns(Exercise.page(1))

      get api_track_exercises_path(
        track,
        criteria: "ru"
      ), headers: @headers, as: :json

      assert_response :ok
    end

    test "index should proxy params for user" do
      setup_user
      track = create :track
      user_track = create(:user_track, user: @current_user, track:)

      Exercise::Search.expects(:call).with(
        user_track,
        criteria: "ru"
      ).returns(Exercise.page(1))

      get api_track_exercises_path(
        track,
        criteria: "ru"
      ), headers: @headers, as: :json

      assert_response :ok
    end

    test "index should search and return exercises" do
      track = create :track
      exercise = create :concept_exercise, track:, title: "Bob"

      get api_track_exercises_path(
        track,
        criteria: "bo"
      ), headers: @headers, as: :json

      assert_response :ok
      expected = {
        exercises: SerializeExercises.([exercise])
      }.to_json
      assert_equal expected, response.body
    end

    test "index should sideload solutions" do
      setup_user

      track = create :track
      user_track = create(:user_track, user: @current_user, track:)

      bob = create :concept_exercise, track:, title: "Bob"
      food = create :concept_exercise, track:, title: "Food"

      solution = create :concept_solution,
        user: @current_user,
        exercise: bob,
        published_at: Time.current,
        mentoring_status: "finished"

      create :concept_solution,
        user: @current_user,
        exercise: food

      get api_track_exercises_path(
        track,
        criteria: "bo",
        sideload: [:solutions]
      ), headers: @headers, as: :json

      assert_response :ok

      expected = {
        exercises: SerializeExercises.([bob], user_track:),
        solutions: SerializeSolutions.(Solution.where(id: solution), @current_user)
      }.to_json
      assert_equal expected, response.body
    end

    test "index should search when not logged in" do
      track = create :track
      exercise = create :concept_exercise, track:, title: "Bob"

      get api_track_exercises_path(track, sideload: [:solutions]), as: :json

      assert_response :ok
      expected = {
        exercises: SerializeExercises.([exercise]),
        solutions: []
      }.to_json
      assert_equal expected, response.body
    end
  end
end
