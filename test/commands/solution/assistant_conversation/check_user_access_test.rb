require "test_helper"

class Solution::AssistantConversation::CheckUserAccessTest < ActiveSupport::TestCase
  test "always allowed for insiders" do
    user = create :user, :insider
    solution = create(:concept_solution, user:)
    create(:solution_assistant_conversation, solution: create(:practice_solution, user:))

    assert Solution::AssistantConversation::CheckUserAccess.(solution)
  end

  test "allowed for non-insider with no previous conversations" do
    user = create :user
    solution = create(:concept_solution, user:)

    assert Solution::AssistantConversation::CheckUserAccess.(solution)
  end

  test "allowed for non-insider on their free exercise" do
    user = create :user
    solution = create(:concept_solution, user:)
    create(:solution_assistant_conversation, solution:)

    assert Solution::AssistantConversation::CheckUserAccess.(solution)
  end

  test "denied for non-insider on a second exercise" do
    user = create :user
    other_solution = create(:practice_solution, user:)
    create(:solution_assistant_conversation, solution: other_solution)
    solution = create(:concept_solution, user:)

    refute Solution::AssistantConversation::CheckUserAccess.(solution)
  end

  test "free exercise is pinned to the first conversation" do
    user = create :user
    first_solution = create(:practice_solution, user:)
    create(:solution_assistant_conversation, solution: first_solution)
    second_solution = create(:concept_solution, user:)
    create(:solution_assistant_conversation, solution: second_solution)

    assert Solution::AssistantConversation::CheckUserAccess.(first_solution)
    refute Solution::AssistantConversation::CheckUserAccess.(second_solution)
  end

  test "other users' conversations don't affect access" do
    user = create :user
    create :solution_assistant_conversation
    solution = create(:concept_solution, user:)

    assert Solution::AssistantConversation::CheckUserAccess.(solution)
  end
end
