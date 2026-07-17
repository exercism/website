require "test_helper"

class Solution::AssistantConversation::AddAssistantMessageTest < ActiveSupport::TestCase
  setup do
    Exercism.secrets.assistant_chat_hmac_secret = "test-assistant-hmac-secret"
  end

  test "appends the message when the signature is valid" do
    solution = create :concept_solution
    content = "Have you considered the tests?"
    timestamp = Time.current.utc.iso8601(3)
    signature = generate_signature(solution, content, timestamp)

    Solution::AssistantConversation::AddAssistantMessage.(solution, content, timestamp, signature)

    assert_equal(
      [{ "role" => "assistant", "content" => content, "timestamp" => timestamp }],
      solution.reload.assistant_conversation.messages
    )
  end

  test "raises and does not save when the signature is invalid" do
    solution = create :concept_solution
    timestamp = Time.current.utc.iso8601(3)

    assert_raises InvalidHMACSignatureError do
      Solution::AssistantConversation::AddAssistantMessage.(solution, "Fabricated", timestamp, "not-a-signature")
    end

    assert_nil solution.reload.assistant_conversation
  end

  private
  def generate_signature(solution, content, timestamp)
    payload = "#{solution.user_id}:#{solution.uuid}:#{content}:#{timestamp}"
    OpenSSL::HMAC.hexdigest('SHA256', Exercism.secrets.assistant_chat_hmac_secret, payload)
  end
end
