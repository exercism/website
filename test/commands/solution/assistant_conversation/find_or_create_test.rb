require "test_helper"

class Solution::AssistantConversation::FindOrCreateTest < ActiveSupport::TestCase
  test "creates a conversation for the solution" do
    solution = create :concept_solution

    conversation = Solution::AssistantConversation::FindOrCreate.(solution)

    assert conversation.persisted?
    assert_equal solution, conversation.solution
    assert_equal solution.user, conversation.user
    assert_empty conversation.messages
  end

  test "returns the existing conversation" do
    solution = create :concept_solution
    existing = create(:solution_assistant_conversation, solution:)

    assert_no_difference -> { Solution::AssistantConversation.count } do
      assert_equal existing, Solution::AssistantConversation::FindOrCreate.(solution)
    end
  end
end
