class Solution::AssistantConversation::AddMessage
  include Mandate

  initialize_with :conversation, :role, :content, :timestamp

  def call
    conversation.with_lock do
      conversation.messages ||= []
      conversation.messages << { role:, content:, timestamp: }
      conversation.save!
    end
  end
end
