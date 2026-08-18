class Solution::AssistantConversation::CheckUserAccess
  include Mandate

  initialize_with :solution

  def call
    return true if user.insider?

    # Non-insiders get one free exercise, ever: whichever exercise they
    # first started a conversation on. Conversations on any other
    # exercise require Insiders.
    return true if first_conversation.nil?

    first_conversation.solution_id == solution.id
  end

  private
  delegate :user, to: :solution

  memoize
  def first_conversation
    user.assistant_conversations.order(:id).first
  end
end
