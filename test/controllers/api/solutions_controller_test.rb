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

    Solution::Search.expects(:call).with(
      @current_user,
      criteria: "ru",
      status: "published",
      mentoring_status: "completed",
      page: "2",
      order: "newest_first"
    ).returns(Solution.page(2))

    get api_solutions_path(
      criteria: "ru",
      status: "published",
      mentoring_status: "completed",
      page: "2",
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
      published_at: Time.current,
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
      serializer: SerializeSolutionsForStudent
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
      solution: SerializeSolutionForStudent.(solution)
    }
    assert_equal expected.to_json, response.body
  end

  test "Show should return iteration if requested" do
    setup_user
    solution = create :concept_solution, user: @current_user
    iteration = create :iteration, solution: solution
    get api_solution_path(solution.uuid, sideloads: [:latest_iteration]), headers: @headers, as: :json

    assert_response 200
    expected = {
      solution: SerializeSolutionForStudent.(solution),
      latest_iteration: SerializeIteration.(iteration)
    }
    assert_equal expected.to_json, response.body
  end

  test "Show should return null iteration if non-existant but requested" do
    setup_user
    solution = create :concept_solution, user: @current_user
    get api_solution_path(solution.uuid, sideloads: [:latest_iteration]), headers: @headers, as: :json

    assert_response 200
    expected = {
      solution: SerializeSolutionForStudent.(solution),
      latest_iteration: nil
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
    setup_user

    exercise = create :concept_exercise
    create :user_track, track: exercise.track, user: @current_user
    solution = create :concept_solution, exercise: exercise, user: @current_user

    patch complete_api_solution_path(solution.uuid),
      headers: @headers, as: :json

    assert_response 200
    assert solution.reload.completed?
  end

  test "complete renders changes in user_track" do
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
    solution = create :concept_solution, exercise: concept_exercise_1, user: @current_user

    patch complete_api_solution_path(solution.uuid),
      headers: @headers, as: :json

    assert_response 200
    assert_equal(
      {
        "exercise" => {
          "slug" => concept_exercise_1.slug,
          "title" => concept_exercise_1.title,
          "icon_name" => concept_exercise_1.icon_name,
          "links" => {
            "self" => track_exercise_path(track, concept_exercise_1)
          }
        },
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
