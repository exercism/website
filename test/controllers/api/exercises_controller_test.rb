require_relative './base_test_case'

module API
  class ExercisesControllerTest < API::BaseTestCase
    ############
    # Complete #
    ############
    test "renders 404 when track not found" do
      setup_user

      patch complete_api_track_exercise_path("ruby", "bob"),
        headers: @headers, as: :json

      assert_response 404
      assert_equal(
        {
          "error" => {
            "type" => "track_not_found",
            "message" => I18n.t("api.errors.track_not_found")
          }
        },
        JSON.parse(response.body)
      )
    end

    test "renders 404 when exercise not found" do
      setup_user

      patch complete_api_track_exercise_path(create(:track).slug, "bob"),
        headers: @headers, as: :json

      assert_response 404
      assert_equal(
        {
          "error" => {
            "type" => "exercise_not_found",
            "message" => I18n.t("api.errors.exercise_not_found")
          }
        },
        JSON.parse(response.body)
      )
    end

    test "renders 404 when track not joined" do
      setup_user

      exercise = create :concept_exercise
      patch complete_api_track_exercise_path(exercise.track.slug, exercise.slug),
        headers: @headers, as: :json

      assert_response 404
      assert_equal(
        {
          "error" => {
            "type" => "track_not_joined",
            "message" => I18n.t("api.errors.track_not_joined")
          }
        },
        JSON.parse(response.body)
      )
    end

    test "renders 404 when solution not found" do
      setup_user

      exercise = create :concept_exercise
      create :user_track, track: exercise.track, user: @current_user
      patch complete_api_track_exercise_path(exercise.track.slug, exercise.slug),
        headers: @headers, as: :json

      assert_response 404
      assert_equal(
        {
          "error" => {
            "type" => "solution_not_found",
            "message" => I18n.t("api.errors.solution_not_found")
          }
        },
        JSON.parse(response.body)
      )
    end

    test "completes exercise" do
      setup_user

      exercise = create :concept_exercise
      create :user_track, track: exercise.track, user: @current_user
      solution = create :concept_solution, exercise: exercise, user: @current_user

      patch complete_api_track_exercise_path(exercise.track.slug, exercise.slug),
        headers: @headers, as: :json

      assert_response 200
      assert solution.reload.completed?
    end

    test "renders changes in user_track" do
      setup_user

      track = create :track
      concept_1 = create :track_concept, track: track
      concept_2 = create :track_concept, track: track

      concept_exercise_1 = create :concept_exercise, track: track, slug: "foo"
      concept_exercise_1.taught_concepts << concept_1
      practice_exercise = create :practice_exercise, track: track, slug: "prac"
      practice_exercise.prerequisites << concept_1

      concept_exercise_2 = create :concept_exercise, track: track, slug: "bar"
      concept_exercise_2.prerequisites << concept_1
      concept_exercise_2.taught_concepts << concept_2

      create :user_track, track: track, user: @current_user
      create :concept_solution, exercise: concept_exercise_1, user: @current_user

      patch complete_api_track_exercise_path(track.slug, concept_exercise_1.slug),
        headers: @headers, as: :json

      assert_response 200
      assert_equal(
        {
          "unlocked_exercises" => [
            {
              "slug" => practice_exercise.slug,
              "title" => practice_exercise.title,
              "icon_name" => practice_exercise.icon_name
            },
            {
              "slug" => concept_exercise_2.slug,
              "title" => concept_exercise_2.title,
              "icon_name" => concept_exercise_2.icon_name
            }
          ],
          "unlocked_concepts" => [
            {
              "slug" => concept_2.slug,
              "name" => concept_2.name
            }
          ],
          "concept_progressions" => [
            {
              "slug" => concept_1.slug,
              "name" => concept_1.name,
              "from" => 0,
              "to" => 1,
              "total" => 2
            }
          ]
        },
        JSON.parse(response.body)
      )
    end
  end
end
