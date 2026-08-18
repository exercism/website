require "test_helper"

class Solution::AssistantConversation::VerifyHMACTest < ActiveSupport::TestCase
  setup do
    Exercism.secrets.assistant_chat_hmac_secret = "test-assistant-hmac-secret"
  end

  test "passes for a valid signature" do
    solution = create :concept_solution
    timestamp = Time.current.utc.iso8601(3)
    signature = generate_signature(solution, "Some advice", timestamp)

    assert Solution::AssistantConversation::VerifyHMAC.(solution, "Some advice", timestamp, signature)
  end

  test "raises for a tampered message" do
    solution = create :concept_solution
    timestamp = Time.current.utc.iso8601(3)
    signature = generate_signature(solution, "Some advice", timestamp)

    assert_raises InvalidHMACSignatureError do
      Solution::AssistantConversation::VerifyHMAC.(solution, "Different advice", timestamp, signature)
    end
  end

  test "raises for a stale timestamp" do
    solution = create :concept_solution
    timestamp = 11.minutes.ago.utc.iso8601(3)
    signature = generate_signature(solution, "Some advice", timestamp)

    assert_raises InvalidHMACSignatureError do
      Solution::AssistantConversation::VerifyHMAC.(solution, "Some advice", timestamp, signature)
    end
  end

  test "raises for a malformed timestamp" do
    solution = create :concept_solution

    assert_raises InvalidHMACSignatureError do
      Solution::AssistantConversation::VerifyHMAC.(solution, "Some advice", "not-a-time", "sig")
    end
  end

  test "raises for a nil signature" do
    solution = create :concept_solution
    timestamp = Time.current.utc.iso8601(3)

    assert_raises InvalidHMACSignatureError do
      Solution::AssistantConversation::VerifyHMAC.(solution, "Some advice", timestamp, nil)
    end
  end

  private
  def generate_signature(solution, content, timestamp)
    payload = "#{solution.user_id}:#{solution.uuid}:#{content}:#{timestamp}"
    OpenSSL::HMAC.hexdigest('SHA256', Exercism.secrets.assistant_chat_hmac_secret, payload)
  end
end
