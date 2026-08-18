# Verifies a conversation JWT presented by the llm-chat-proxy worker
# when it fetches the exercise context for a solution. Returns true if
# the token is validly signed, unexpired, and was minted for this solution.
class Solution::AssistantConversation::VerifyConversationToken
  include Mandate

  initialize_with :token, :solution

  def call
    payload, = JWT.decode(
      token.to_s,
      Exercism.secrets.assistant_chat_jwt_secret,
      true,
      { algorithm: 'HS256' }
    )

    payload["solution_uuid"] == solution.uuid
  rescue JWT::DecodeError
    false
  end
end
