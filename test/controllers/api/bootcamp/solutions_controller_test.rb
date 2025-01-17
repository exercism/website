require_relative '../base_test_case'

class API::Bootcamp::SolutionsControllerTest < API::BaseTestCase
  test "complete: proxies and returns 200" do
    freeze_time do
      user = create :user
      solution = create(:bootcamp_solution, user:)
      create :bootcamp_user_project, user:, project: solution.project

      setup_user(user)
      patch complete_api_bootcamp_solution_url(solution), headers: @headers

      assert_response :ok
      assert_json_response({ next_exercise: nil })
    end
  end

  test "complete: returns next exercise" do
    freeze_time do
      user = create :user
      solution = create(:bootcamp_solution, user:)
      project = solution.project
      create(:bootcamp_user_project, user:, project:)
      next_exercise = create(:bootcamp_exercise, project:)

      setup_user(user)
      patch complete_api_bootcamp_solution_url(solution), headers: @headers

      assert_response :ok
      assert_json_response({
        next_exercise: SerializeBootcampExercise.(next_exercise)
      })
    end
  end
end
