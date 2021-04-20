require_relative './base_test_case'

module API
  class ExercisesControllerTest < API::BaseTestCase
    #########
    # INDEX #
    #########
    test "index should proxy params" do
      track = create :track

      Exercise::Search.expects(:call).with(
        track,
        criteria: "ru"
      ).returns(Exercise.page(1))

      get api_track_exercises_path(
        track,
        criteria: "ru"
      ), headers: @headers, as: :json

      assert_response :success
    end

    test "index should search and return exercises" do
      track = create :track
      exercise = create :concept_exercise, track: track, title: "Bob"

      get api_track_exercises_path(
        track,
        criteria: "bo"
      ), headers: @headers, as: :json

      assert_response :success
      expected = {
        exercises: SerializeExercises.([exercise])
      }.to_json
      assert_equal expected, response.body
    end

    test "index should sideload solutions" do
      setup_user

      track = create :track
      user_track = create :user_track, user: @current_user, track: track

      bob = create :concept_exercise, track: track, title: "Bob"
      food = create :concept_exercise, track: track, title: "Food"

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

      assert_response :success

      expected = {
        exercises: SerializeExercises.([bob], user_track: user_track),
        solutions: SerializeSolutions.(Solution.where(id: solution), @current_user)
      }.to_json
      assert_equal expected, response.body
    end
  end
end
