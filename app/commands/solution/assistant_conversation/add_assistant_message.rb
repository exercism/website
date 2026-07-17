class Solution::AssistantConversation::AddAssistantMessage
  include Mandate

  initialize_with :solution, :content, :timestamp, :signature

  def call
    Solution::AssistantConversation::VerifyHMAC.(solution, content, timestamp, signature)

    Solution::AssistantConversation::AddMessage.(conversation, "assistant", content, timestamp)
  end

  private
  memoize
  def conversation
    Solution::AssistantConversation::FindOrCreate.(solution)
  end
end
