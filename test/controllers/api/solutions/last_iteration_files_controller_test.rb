require_relative '../base_test_case'

class API::Solutions::LastIterationFilesControllerTest < API::BaseTestCase
  ###
  # Index
  ###
  test "index should return 400 when there are no iterations submitted yet" do
    user = create :user
    setup_user(user)
    solution = create(:concept_solution, user:)

    get api_solution_last_iteration_files_path(solution.uuid), headers: @headers, as: :json

    assert_response :bad_request
    expected = { error: {
      type: "no_iterations_submitted_yet",
      message: I18n.t('api.errors.no_iterations_submitted_yet')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end
end
