require_relative '../base_test_case'

class API::Solutions::AssistantConversationsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_solution_assistant_conversation_path, args: 1, method: :post
  guard_incorrect_token! :user_messages_api_solution_assistant_conversation_path, args: 1, method: :post
  guard_incorrect_token! :assistant_messages_api_solution_assistant_conversation_path, args: 1, method: :post

  setup do
    Exercism.secrets.assistant_chat_jwt_secret = "test-assistant-jwt-secret"
    Exercism.secrets.assistant_chat_hmac_secret = "test-assistant-hmac-secret"
  end

  ###
  # create
  ###
  test "create should 404 if the solution doesn't exist" do
    setup_user

    post api_solution_assistant_conversation_path('xxx'), headers: @headers, as: :json

    assert_response :not_found
  end

  test "create should 403 if the solution belongs to someone else" do
    setup_user
    solution = create :concept_solution

    post api_solution_assistant_conversation_path(solution.uuid), headers: @headers, as: :json

    assert_response :forbidden
    assert_equal "solution_not_accessible", JSON.parse(response.body).dig("error", "type")
  end

  test "create should 403 without a captcha token" do
    setup_user
    solution = create :concept_solution, user: @current_user

    post api_solution_assistant_conversation_path(solution.uuid), headers: @headers, as: :json

    assert_response :forbidden
    assert_equal "invalid_captcha", JSON.parse(response.body).dig("error", "type")
  end

  test "create should 403 if the captcha fails verification" do
    setup_user
    solution = create :concept_solution, user: @current_user
    Captcha::VerifyTurnstileToken.stubs(call: false)

    post api_solution_assistant_conversation_path(solution.uuid),
      params: { cf_turnstile_response: "token" },
      headers: @headers, as: :json

    assert_response :forbidden
    assert_equal "invalid_captcha", JSON.parse(response.body).dig("error", "type")
  end

  test "create should 403 when the free conversation is used up" do
    setup_user
    create(:solution_assistant_conversation, solution: create(:practice_solution, user: @current_user))
    solution = create :concept_solution, user: @current_user
    Captcha::VerifyTurnstileToken.stubs(call: true)

    post api_solution_assistant_conversation_path(solution.uuid),
      params: { cf_turnstile_response: "token" },
      headers: @headers, as: :json

    assert_response :forbidden
    assert_equal "assistant_conversation_not_accessible", JSON.parse(response.body).dig("error", "type")
  end

  test "create should return a conversation token" do
    setup_user
    solution = create :concept_solution, user: @current_user
    Captcha::VerifyTurnstileToken.stubs(call: true)

    post api_solution_assistant_conversation_path(solution.uuid),
      params: { cf_turnstile_response: "token" },
      headers: @headers, as: :json

    assert_response :ok
    token = JSON.parse(response.body)["token"]
    payload, = JWT.decode(token, Exercism.secrets.assistant_chat_jwt_secret, true, { algorithm: 'HS256' })
    assert_equal solution.uuid, payload["solution_uuid"]
  end

  ###
  # user_messages
  ###
  test "user_messages should save the message" do
    setup_user
    solution = create :concept_solution, user: @current_user
    timestamp = Time.current.utc.iso8601(3)

    post user_messages_api_solution_assistant_conversation_path(solution.uuid),
      params: { content: "Help!", timestamp: },
      headers: @headers, as: :json

    assert_response :ok
    assert_equal "Help!", solution.reload.assistant_conversation.messages.last["content"]
  end

  test "user_messages should 403 for someone else's solution" do
    setup_user
    solution = create :concept_solution

    post user_messages_api_solution_assistant_conversation_path(solution.uuid),
      params: { content: "Help!", timestamp: Time.current.utc.iso8601(3) },
      headers: @headers, as: :json

    assert_response :forbidden
  end

  ###
  # assistant_messages
  ###
  test "assistant_messages should save a correctly signed message" do
    setup_user
    solution = create :concept_solution, user: @current_user
    content = "Look at the failing test."
    timestamp = Time.current.utc.iso8601(3)
    payload = "#{solution.user_id}:#{solution.uuid}:#{content}:#{timestamp}"
    signature = OpenSSL::HMAC.hexdigest('SHA256', Exercism.secrets.assistant_chat_hmac_secret, payload)

    post assistant_messages_api_solution_assistant_conversation_path(solution.uuid),
      params: { content:, timestamp:, signature: },
      headers: @headers, as: :json

    assert_response :ok
    assert_equal content, solution.reload.assistant_conversation.messages.last["content"]
  end

  test "assistant_messages should 401 for an invalid signature" do
    setup_user
    solution = create :concept_solution, user: @current_user

    post assistant_messages_api_solution_assistant_conversation_path(solution.uuid),
      params: { content: "Fabricated", timestamp: Time.current.utc.iso8601(3), signature: "bad" },
      headers: @headers, as: :json

    assert_response :unauthorized
    assert_equal "invalid_signature", JSON.parse(response.body).dig("error", "type")
    assert_nil solution.reload.assistant_conversation
  end
end
