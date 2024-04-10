require_relative '../base_test_case'

class API::Solutions::SubmissionAIHelpControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_solution_submission_ai_help_path, args: 2, method: :post

  test "create should 404 if the solution doesn't exist" do
    setup_user
    solution = create :concept_solution
    post api_solution_submission_ai_help_path(solution.uuid, 999), headers: @headers, as: :json
    assert_response :not_found

    sleep(0.1)
  end

  test "create should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution
    submission = create(:submission, solution:)

    post api_solution_submission_ai_help_path(solution.uuid, submission.uuid), headers: @headers, as: :json

    assert_response :forbidden
    expected = { error: {
      type: "submission_not_accessible",
      message: I18n.t('api.errors.submission_not_accessible')
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual

    sleep(0.1)
  end

  test "create should return 402 if rate limit is hit" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create(:submission, solution:)
    @current_user.update!(usages: { chatgpt: { '4.0' => 10, '3.5' => 100 } })

    post api_solution_submission_ai_help_path(solution.uuid, submission.uuid), headers: @headers, as: :json

    assert_response 402
    expected = { error: {
      type: "too_many_requests",
      message: I18n.t('api.errors.too_many_requests'),
      usage_type: 'chatgpt',
      usage: { "4.0": 10, "3.5": 100 } # rubocop:disable Naming/VariableNumber
    } }
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual

    sleep(0.1)
  end

  test "create should hit chatgpt and return 202" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create(:submission, solution:)

    stub_request(:post, "http://local.exercism.io:3026/ask_chatgpt")

    post api_solution_submission_ai_help_path(solution.uuid, submission.uuid), headers: @headers, as: :json

    assert_response 202

    sleep(0.1)
  end

  test "create return existing record if exists" do
    setup_user
    solution = create :concept_solution, user: @current_user
    submission = create(:submission, solution:)
    create(:submission_ai_help_record, submission:)

    stub_request(:post, "http://local.exercism.io:3026/ask_chatgpt")

    post api_solution_submission_ai_help_path(solution.uuid, submission.uuid), headers: @headers, as: :json

    assert_response 200
  end
end
