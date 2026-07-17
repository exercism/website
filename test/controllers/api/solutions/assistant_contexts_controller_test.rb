require_relative '../base_test_case'

class API::Solutions::AssistantContextsControllerTest < API::BaseTestCase
  setup do
    Exercism.secrets.assistant_chat_jwt_secret = "test-assistant-jwt-secret"
  end

  test "show should 404 if the solution doesn't exist" do
    get api_solution_assistant_context_path('xxx'), as: :json

    assert_response :not_found
  end

  test "show should 403 without a conversation token" do
    solution = create :concept_solution

    get api_solution_assistant_context_path(solution.uuid), as: :json

    assert_response :forbidden
  end

  test "show should 403 with a token for a different solution" do
    solution = create :concept_solution
    other_token = Solution::AssistantConversation::CreateConversationToken.(create(:concept_solution))

    get api_solution_assistant_context_path(solution.uuid),
      headers: { 'Authorization' => "Bearer #{other_token}" }, as: :json

    assert_response :forbidden
  end

  test "show should return the exercise context" do
    solution = create :concept_solution
    token = Solution::AssistantConversation::CreateConversationToken.(solution)

    get api_solution_assistant_context_path(solution.uuid),
      headers: { 'Authorization' => "Bearer #{token}" }, as: :json

    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal solution.track.slug, body.dig("track", "slug")
    assert_equal solution.exercise.slug, body.dig("exercise", "slug")
    assert body.key?("introduction")
    assert body.key?("instructions")
    assert body["tests"].is_a?(Array)
  end
end
