require_relative './base_test_case'

class API::SolutionsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_solutions_path
  guard_incorrect_token! :api_solution_path, args: 1

  #########
  # INDEX #
  #########
  test "index should proxy params" do
    setup_user
    create :concept_solution

    Solution::SearchUserSolutions.expects(:call).with(
      @current_user,
      criteria: "ru",
      status: "published",
      mentoring_status: "completed",
      track_slug: "ruby",
      page: "2",
      per: "10",
      order: "newest_first"
    ).returns(Solution.page(2))

    get api_solutions_path(
      criteria: "ru",
      track_id: "ruby",
      status: "published",
      mentoring_status: "completed",
      page: "2",
      per_page: "10",
      order: "newest_first"
    ), headers: @headers, as: :json

    assert_response :success
  end

  test "index should search and return solutions" do
    setup_user
    ruby = create :track, title: "Ruby"
    ruby_bob = create :concept_exercise, track: ruby, title: "Bob"
    create :concept_solution,
      user: @current_user,
      exercise: ruby_bob,
      status: :published,
      mentoring_status: "finished"

    get api_solutions_path(
      criteria: "ru",
      status: "published",
      mentoring_status: "finished",
      page: 1
    ), headers: @headers, as: :json

    assert_response :success
    serializer = SerializePaginatedCollection.(
      Solution.page(1),
      serializer: SerializeSolutions,
      serializer_args: @current_user
    )
    assert_equal serializer.to_json, response.body
  end

  ############
  # Show #
  ############
  test "Show renders 404 when solution not found" do
    setup_user

    get api_solution_path("xxx"),
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

  test "Show should 404 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    get api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response 403
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "Show should return solution by default" do
    setup_user
    solution = create :concept_solution, user: @current_user
    get api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response 200
    expected = {
      solution: SerializeSolution.(solution)
    }
    assert_equal expected.to_json, response.body
  end

  test "Show should return iterations if requested" do
    setup_user
    solution = create :concept_solution, user: @current_user
    iteration = create :iteration, solution: solution
    get api_solution_path(solution.uuid, sideload: [:iterations]), headers: @headers, as: :json

    assert_response 200
    expected = {
      solution: SerializeSolution.(solution),
      iterations: [SerializeIteration.(iteration)]
    }
    assert_equal expected.to_json, response.body
  end

  ############
  # Complete #
  ############
  test "complete renders 404 when solution not found" do
    setup_user

    patch complete_api_solution_path("xxx"),
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

  test "complete should 404 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    patch complete_api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response 403
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "complete renders 404 when track not joined" do
    setup_user

    solution = create :concept_solution, user: @current_user
    patch complete_api_solution_path(solution.uuid),
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

  test "complete completes exercise" do
    freeze_time do
      setup_user

      exercise = create :concept_exercise
      create :user_track, track: exercise.track, user: @current_user
      solution = create :concept_solution, exercise: exercise, user: @current_user

      patch complete_api_solution_path(solution.uuid),
        headers: @headers, as: :json

      assert_response 200

      solution.reload
      assert_equal Time.current, solution.completed_at
      assert_nil solution.published_at
      assert_equal :completed, solution.status
    end
  end

  test "publishes if requested" do
    freeze_time do
      setup_user

      exercise = create :concept_exercise
      create :user_track, track: exercise.track, user: @current_user
      solution = create :concept_solution, exercise: exercise, user: @current_user
      create :iteration, solution: solution

      patch complete_api_solution_path(solution.uuid, publish: true),
        headers: @headers, as: :json

      assert_response 200

      solution.reload
      assert_equal Time.current, solution.completed_at
      assert_equal Time.current, solution.published_at
      assert_equal :published, solution.status
    end
  end

  test "complete renders changes in user_track" do
    freeze_time do
      setup_user

      track = create :track
      concept_1 = create :track_concept, track: track
      concept_2 = create :track_concept, track: track

      concept_exercise_1 = create :concept_exercise, track: track, slug: "lasagna"
      concept_exercise_1.taught_concepts << concept_1

      concept_exercise_2 = create :concept_exercise, track: track, slug: "concept-exercise-2"
      concept_exercise_2.taught_concepts << concept_2
      concept_exercise_2.prerequisites << concept_1

      practice_exercise_1 = create :practice_exercise, track: track, slug: "two-fer"
      practice_exercise_1.practiced_concepts << concept_1
      practice_exercise_1.prerequisites << concept_1

      practice_exercise_2 = create :practice_exercise, track: track, slug: "bob"
      practice_exercise_2.prerequisites << concept_1

      practice_exercise_3 = create :practice_exercise, track: track, slug: "leap"
      practice_exercise_3.prerequisites << concept_2

      user_track = create :user_track, track: track, user: @current_user
      solution = create :concept_solution, exercise: concept_exercise_1, user: @current_user

      patch complete_api_solution_path(solution.uuid),
        headers: @headers, as: :json

      assert_response 200
      expected = {
        track: SerializeTrack.(solution.track, user_track),
        exercise: SerializeExercise.(solution.exercise, user_track: user_track),
        unlocked_exercises: [concept_exercise_2, practice_exercise_1, practice_exercise_2].map do |exercise|
          SerializeExercise.(exercise, user_track: user_track)
        end,
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
      }.to_json
      assert_equal expected, response.body
    end
  end
end
