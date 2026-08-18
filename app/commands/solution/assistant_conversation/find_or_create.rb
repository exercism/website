class Solution::AssistantConversation::FindOrCreate
  include Mandate

  initialize_with :solution

  def call
    Solution::AssistantConversation.find_by(solution:) ||
      Solution::AssistantConversation.create!(solution:, user: solution.user, messages: [])
  rescue ActiveRecord::RecordNotUnique
    Solution::AssistantConversation.find_by!(solution:)
  end
end
