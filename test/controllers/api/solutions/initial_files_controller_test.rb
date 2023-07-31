require_relative '../base_test_case'

module API
  module Solutions
    class InitialFilesControllerTest < API::BaseTestCase
      guard_incorrect_token! :api_solution_initial_files_path, args: 1, method: :get

      test "renders 404 when solution not found" do
        setup_user

        get api_solution_initial_files_path(1), headers: @headers, as: :json

        assert_response :not_found
        assert_equal(
          {
            "error" => {
              "type" => "solution_not_found",
              "message" => "This solution could not be found"
            }
          },
          JSON.parse(response.body)
        )
      end

      test "renders 403 when solution not accessible" do
        setup_user
        solution = create :practice_solution

        get api_solution_initial_files_path(solution.uuid), headers: @headers, as: :json

        assert_response :forbidden
        assert_equal(
          {
            "error" => {
              "type" => "solution_not_accessible",
              "message" => "You do not have permission to view this solution"
            }
          },
          JSON.parse(response.body)
        )
      end
    end
  end
end
