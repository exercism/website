require_relative '../base_test_case'

class API::Bootcamp::SolutionsControllerTest < API::BaseTestCase
  test "complete: proxies and returns 200" do
    freeze_time do
      user = create :user, :with_bootcamp_data
      solution = create(:bootcamp_solution, user:)

      setup_user(user)
      patch complete_api_bootcamp_solution_url(solution), headers: @headers

      assert_response :ok
      assert_json_response({
        next_exercise: nil,
        completed_level_idx: 1,
        next_level_idx: nil
      })
    end
  end

  test "complete: returns next exercise" do
    freeze_time do
      user = create :user, :with_bootcamp_data
      solution = create(:bootcamp_solution, user:)
      project = solution.project
      create(:bootcamp_user_project, user:, project:)
      next_exercise = create(:bootcamp_exercise, project:)

      setup_user(user)
      patch complete_api_bootcamp_solution_url(solution), headers: @headers

      assert_response :ok
      assert_json_response({
        next_exercise: SerializeBootcampExercise.(next_exercise),
        completed_level_idx: nil,
        next_level_idx: nil
      })
    end
  end

  # rubocop:disable Naming/VariableNumber
  test "complete: handles completed_level_idx properly" do
    Bootcamp::Settings.instance.update(level_idx: 2)

    freeze_time do
      user = create :user, :with_bootcamp_data
      3.times { create :bootcamp_level }
      l1e1 = create(:bootcamp_exercise, level_idx: 1)
      l1e2 = create(:bootcamp_exercise, level_idx: 1)
      l2e1 = create(:bootcamp_exercise, level_idx: 2)
      solutions = [l1e1, l1e2, l2e1].map { |exercise| create(:bootcamp_solution, user:, exercise:) }

      setup_user(user)

      patch complete_api_bootcamp_solution_url(solutions.first), headers: @headers
      assert_response :ok
      assert_json_response({
        next_exercise: SerializeBootcampExercise.(l1e2),
        completed_level_idx: nil,
        next_level_idx: nil
      })

      patch complete_api_bootcamp_solution_url(solutions.second), headers: @headers
      assert_response :ok
      assert_json_response({
        next_exercise: SerializeBootcampExercise.(l2e1),
        completed_level_idx: 1,
        next_level_idx: 2
      })

      patch complete_api_bootcamp_solution_url(solutions.third), headers: @headers
      assert_response :ok
      assert_json_response({
        next_exercise: nil,
        completed_level_idx: 2,
        next_level_idx: nil
      })
    end
  end
  # rubocop:enable Naming/VariableNumber
end
