require_relative './base_test_case'

class API::SolutionsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_solutions_path
  guard_incorrect_token! :api_solution_path, args: 1
  guard_incorrect_token! :diff_api_solution_path, args: 1
  guard_incorrect_token! :sync_api_solution_path, args: 1, method: :patch
  guard_incorrect_token! :complete_api_solution_path, args: 1, method: :patch
  guard_incorrect_token! :publish_api_solution_path, args: 1, method: :patch
  guard_incorrect_token! :unpublish_api_solution_path, args: 1, method: :patch
  guard_incorrect_token! :published_iteration_api_solution_path, args: 1, method: :patch

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
      sync_status: "up_to_date",
      tests_status: "passed",
      head_tests_status: "failed",
      track_slug: "ruby",
      page: "2",
      per: "10",
      order: "newest_first"
    ).returns(Solution.page(2))

    get api_solutions_path(
      criteria: "ru",
      track_slug: "ruby",
      status: "published",
      mentoring_status: "completed",
      sync_status: "up_to_date",
      tests_status: "passed",
      head_tests_status: "failed",
      page: "2",
      per_page: "10",
      order: "newest_first"
    ), headers: @headers, as: :json

    assert_response :ok
  end

  test "index should search and return solutions" do
    Solution::SearchUserSolutions::Fallback.expects(:call).never

    setup_user
    ruby = create :track, title: "Ruby"
    ruby_bob = create :concept_exercise, track: ruby, title: "Bob"
    create :concept_solution,
      user: @current_user,
      exercise: ruby_bob,
      status: :published,
      mentoring_status: "finished"

    wait_for_opensearch_to_be_synced

    get api_solutions_path(
      criteria: "ru",
      status: "published",
      mentoring_status: "finished",
      page: 1
    ), headers: @headers, as: :json

    assert_response :ok
    serializer = SerializePaginatedCollection.(
      Solution.page(1),
      serializer: SerializeSolutions,
      serializer_args: @current_user
    )
    assert_equal serializer.to_json, response.body
  end

  ########
  # Show #
  ########
  test "Show renders 404 when solution not found" do
    setup_user

    get api_solution_path("xxx"),
      headers: @headers, as: :json

    assert_response :not_found
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

  test "Show should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    get api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :forbidden
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

    assert_response :ok
    expected = {
      solution: SerializeSolution.(solution)
    }
    assert_equal expected.to_json, response.body
  end

  test "Show should return iterations if requested" do
    setup_user
    solution = create :concept_solution, user: @current_user
    iteration = create(:iteration, solution:)
    get api_solution_path(solution.uuid, sideload: [:iterations]), headers: @headers, as: :json

    assert_response :ok
    expected = {
      solution: SerializeSolution.(solution),
      iterations: [SerializeIteration.(iteration)]
    }
    assert_equal expected.to_json, response.body
  end

  ########
  # Diff #
  ########
  test "Diff renders 404 when solution not found" do
    setup_user

    get diff_api_solution_path("xxx"),
      headers: @headers, as: :json

    assert_response :not_found
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

  test "Diff should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    get diff_api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "Diff returns 400 if diff does not contain files" do
    user = create :user
    setup_user(user)
    solution = create(:concept_solution, user:)
    get diff_api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :bad_request
  end

  test "Bugsnag is alerted if diff does not contain files" do
    user = create :user
    setup_user(user)
    solution = create(:concept_solution, user:)
    Bugsnag.expects(:notify).with(RuntimeError.new("No files were found during solution diff"))

    get diff_api_solution_path(solution.uuid), headers: @headers, as: :json
  end

  ########
  # Sync #
  ########
  test "Sync renders 404 when solution not found" do
    setup_user

    patch sync_api_solution_path("xxx"),
      headers: @headers, as: :json

    assert_response :not_found
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

  test "Sync should work correctly" do
    setup_user
    solution = create :concept_solution, user: @current_user
    Solution::UpdateToLatestExerciseVersion.expects(:call).with(solution)

    patch sync_api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :ok
  end

  ############
  # Complete #
  ############
  test "complete renders 404 when solution not found" do
    setup_user

    patch complete_api_solution_path("xxx"),
      headers: @headers, as: :json

    assert_response :not_found
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

  test "complete should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    patch complete_api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :forbidden
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
    create(:iteration, solution:)

    patch complete_api_solution_path(solution.uuid),
      headers: @headers, as: :json

    assert_response :not_found
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

  test "complete renders 400 when solution has no iterations" do
    setup_user

    exercise = create :concept_exercise
    create :user_track, track: exercise.track, user: @current_user
    solution = create :concept_solution, exercise:, user: @current_user

    patch complete_api_solution_path(solution.uuid),
      headers: @headers, as: :json

    assert_response :bad_request
    assert_equal(
      {
        "error" => {
          "type" => "solution_without_iterations",
          "message" => I18n.t("api.errors.solution_without_iterations")
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
      solution = create :concept_solution, exercise:, user: @current_user
      create(:iteration, solution:)

      patch complete_api_solution_path(solution.uuid),
        headers: @headers, as: :json

      assert_response :ok

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
      solution = create :concept_solution, exercise:, user: @current_user
      create(:iteration, solution:)

      patch complete_api_solution_path(solution.uuid, publish: true),
        headers: @headers, as: :json

      assert_response :ok

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

      concept_1 = create(:concept, track:)
      concept_2 = create(:concept, track:)

      concept_exercise_1 = create :concept_exercise, track:, slug: "lasagna"
      concept_exercise_1.taught_concepts << concept_1

      concept_exercise_2 = create :concept_exercise, track:, slug: "concept-exercise-2"
      concept_exercise_2.taught_concepts << concept_2
      concept_exercise_2.prerequisites << concept_1

      practice_exercise_1 = create :practice_exercise, track:, slug: "two-fer"
      practice_exercise_1.practiced_concepts << concept_1
      practice_exercise_1.prerequisites << concept_1

      practice_exercise_2 = create :practice_exercise, track:, slug: "bob"
      practice_exercise_2.prerequisites << concept_1

      practice_exercise_3 = create :practice_exercise, track:, slug: "leap"
      practice_exercise_3.prerequisites << concept_2

      user_track = create :user_track, track:, user: @current_user
      solution = create :concept_solution, exercise: concept_exercise_1, user: @current_user
      submission = create(:submission, solution:)
      create(:iteration, submission:)

      patch complete_api_solution_path(solution.uuid),
        headers: @headers, as: :json

      user_track.reload

      assert_response :ok
      expected = {
        track: SerializeTrack.(solution.track, user_track),
        exercise: SerializeExercise.(solution.exercise, user_track:),
        unlocked_exercises: [concept_exercise_2, practice_exercise_1, practice_exercise_2].map do |exercise|
          SerializeExercise.(exercise, user_track:)
        end,
        "unlocked_concepts" => [
          {
            "slug" => concept_2.slug,
            "name" => concept_2.name,
            "links" => {
              "self" => Exercism::Routes.track_concept_path(concept_2.track, concept_2)
            }
          }
        ],
        "concept_progressions" => [
          {
            "slug" => concept_1.slug,
            "name" => concept_1.name,
            "from" => 0,
            "to" => 1,
            "total" => 2,
            "links" => {
              "self" => Exercism::Routes.track_concept_path(concept_1.track, concept_1)
            }
          }
        ]
      }.to_json

      assert_equal expected, response.body
    end
  end

  ############
  # Publish #
  ############
  test "publish renders 404 when solution not found" do
    setup_user

    patch publish_api_solution_path("xxx"),
      headers: @headers, as: :json

    assert_response :not_found
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

  test "publish should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    patch publish_api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "publish renders 404 when track not joined" do
    setup_user

    solution = create :concept_solution, user: @current_user
    create(:iteration, solution:)

    patch publish_api_solution_path(solution.uuid),
      headers: @headers, as: :json

    assert_response :not_found
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

  test "publish renders 400 when solution not completed and has no iterations" do
    setup_user

    exercise = create :concept_exercise
    create :user_track, track: exercise.track, user: @current_user
    solution = create :concept_solution, exercise:, user: @current_user, completed_at: nil

    patch publish_api_solution_path(solution.uuid, publish: true),
      headers: @headers, as: :json

    assert_response :bad_request
    assert_equal(
      {
        "error" => {
          "type" => "solution_without_iterations",
          "message" => I18n.t("api.errors.solution_without_iterations")
        }
      },
      JSON.parse(response.body)
    )
  end

  test "publish completes the solution if not already completed" do
    freeze_time do
      setup_user

      exercise = create :concept_exercise
      create :user_track, track: exercise.track, user: @current_user
      solution = create :concept_solution, exercise:, user: @current_user, completed_at: nil
      create(:iteration, solution:)

      patch publish_api_solution_path(solution.uuid, publish: true),
        headers: @headers, as: :json

      assert_response :ok

      solution.reload
      assert_equal Time.current, solution.completed_at
      assert_equal Time.current, solution.published_at
      assert_equal :published, solution.status
    end
  end

  test "publish publishes the solution" do
    freeze_time do
      setup_user

      exercise = create :concept_exercise
      create :user_track, track: exercise.track, user: @current_user
      solution = create :concept_solution, exercise:, user: @current_user, completed_at: Time.current
      create(:iteration, solution:)

      patch publish_api_solution_path(solution.uuid, publish: true),
        headers: @headers, as: :json

      assert_response :ok

      solution.reload
      assert_equal Time.current, solution.completed_at
      assert_equal Time.current, solution.published_at
      assert_equal :published, solution.status
    end
  end

  ############
  # Unpublish #
  ############
  test "unpublish renders 404 when solution not found" do
    setup_user

    patch unpublish_api_solution_path("xxx"),
      headers: @headers, as: :json

    assert_response :not_found
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

  test "unpublish should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    patch unpublish_api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "solution_not_accessible",
      message: I18n.t('api.errors.solution_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "unpublish renders 404 when track not joined" do
    setup_user

    solution = create :concept_solution, user: @current_user
    patch unpublish_api_solution_path(solution.uuid),
      headers: @headers, as: :json

    assert_response :not_found
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

  test "unpublish unpublishes the solution" do
    freeze_time do
      setup_user

      exercise = create :concept_exercise
      create :user_track, track: exercise.track, user: @current_user
      solution = create :concept_solution, exercise:, user: @current_user, completed_at: Time.current
      create(:iteration, solution:)

      patch unpublish_api_solution_path(solution.uuid, publish: true),
        headers: @headers, as: :json

      assert_response :ok

      solution.reload
      assert_equal Time.current, solution.completed_at
      assert_nil solution.published_at
      assert_nil solution.published_iteration_id
      assert_equal :completed, solution.status
    end
  end

  ###############
  # Unlock help #
  ###############
  test "unlock_help renders 404 when solution not found" do
    setup_user

    patch unlock_help_api_solution_path("xxx"), headers: @headers, as: :json

    assert_response :not_found
    expected = {
      error: {
        type: "solution_not_found",
        message: I18n.t("api.errors.solution_not_found")
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "unlock_help should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    patch unlock_help_api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :forbidden
    expected = {
      error: {
        type: "solution_not_accessible",
        message: I18n.t('api.errors.solution_not_accessible')
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "unlock_help renders 400 when solution has not been downloaded nor submitted" do
    setup_user

    exercise = create :concept_exercise
    create :user_track, track: exercise.track, user: @current_user
    solution = create :concept_solution, exercise:, user: @current_user, completed_at: nil

    patch unlock_help_api_solution_path(solution.uuid), headers: @headers, as: :json

    assert_response :bad_request
    expected = {
      error: {
        type: "solution_unlock_help_not_accessible",
        message: I18n.t("api.errors.solution_unlock_help_not_accessible")
      }
    }
    assert_equal expected, JSON.parse(response.body, symbolize_names: true)
  end

  test "unlock_help unlocks help for the solution" do
    freeze_time do
      setup_user

      exercise = create :concept_exercise
      create :user_track, track: exercise.track, user: @current_user
      solution = create :concept_solution, exercise:, user: @current_user, completed_at: Time.current
      create(:iteration, solution:)

      # Sanity check
      refute solution.unlocked_help?

      patch unlock_help_api_solution_path(solution.uuid), headers: @headers, as: :json

      assert_response :ok
      assert solution.reload.unlocked_help?
    end
  end
end
