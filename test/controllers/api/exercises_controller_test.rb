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

      ruby = create :track, slug: :ruby
      user_track = create(:user_track, user: @current_user, track: ruby)

      js = create :track, slug: :javascript
      create(:user_track, user: @current_user, track: js)

      ruby_bob = create :concept_exercise, track: ruby, title: "Bob"
      ruby_food = create :concept_exercise, track: ruby, title: "Food"
      js_acronym = create :concept_exercise, track: js, title: "Acronym"

      ruby_bob_solution = create :concept_solution,
        user: @current_user,
        exercise: ruby_bob,
        published_at: Time.current,
        mentoring_status: "finished"

      ruby_food_solution = create :concept_solution,
        user: @current_user,
        exercise: ruby_food

      create :concept_solution,
        user: @current_user,
        exercise: js_acronym

      get api_track_exercises_path(
        ruby,
        criteria: "bo",
        sideload: [:solutions]
      ), headers: @headers, as: :json

      assert_response :ok

      expected = {
        exercises: SerializeExercises.([ruby_bob], user_track:),
        solutions: SerializeSolutions.([ruby_bob_solution, ruby_food_solution], @current_user)
      }.to_json
      assert_equal expected, response.body
    end

    #########
    # START #
    #########
    test "start should return 403 when user has not joined track" do
      setup_user
      track = create :track
      exercise = create(:practice_exercise, track:)

      patch start_api_track_exercise_path(track, exercise),
        headers: @headers, as: :json

      assert_response :forbidden
      expected = {
        error: {
          type: "track_not_joined",
          message: I18n.t("api.errors.track_not_joined")
        }
      }
      assert_equal expected, response.parsed_body.deep_symbolize_keys
    end

    test "start should return 403 when exercise is locked" do
      setup_user
      track = create :track
      create(:user_track, user: @current_user, track:)
      exercise = create(:practice_exercise, track:)
      UserTrack.any_instance.stubs(:exercise_unlocked?).with(exercise).returns(false)

      patch start_api_track_exercise_path(track, exercise),
        headers: @headers, as: :json

      assert_response :forbidden
      expected = {
        error: {
          type: "exercise_locked",
          message: I18n.t("api.errors.exercise_locked")
        }
      }
      assert_equal expected, response.parsed_body.deep_symbolize_keys
    end

    test "start should create solution and return exercise link" do
      setup_user
      track = create :track
      create(:user_track, user: @current_user, track:)
      exercise = create(:practice_exercise, track:)
      UserTrack.any_instance.stubs(:exercise_unlocked?).with(exercise).returns(true)

      patch start_api_track_exercise_path(track, exercise),
        headers: @headers, as: :json

      assert_response :ok
      expected = {
        links: {
          exercise: Exercism::Routes.edit_track_exercise_url(track, exercise)
        }
      }
      assert_equal expected.to_json, response.body
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
