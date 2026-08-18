class Solution::AssistantConversation::AddUserMessage
  include Mandate

  initialize_with :solution, :content, :timestamp

  def call
    Solution::AssistantConversation::AddMessage.(conversation, "user", content, timestamp)
  end

  private
  memoize
  def conversation
    Solution::AssistantConversation::FindOrCreate.(solution)
  end
end
