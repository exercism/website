require "test_helper"

class Solution::AssistantConversation::VerifyConversationTokenTest < ActiveSupport::TestCase
  setup do
    Exercism.secrets.assistant_chat_jwt_secret = "test-assistant-jwt-secret"
  end

  test "passes for a token minted for the solution" do
    solution = create :concept_solution
    token = Solution::AssistantConversation::CreateConversationToken.(solution)

    assert Solution::AssistantConversation::VerifyConversationToken.(token, solution)
  end

  test "fails for a token minted for a different solution" do
    solution = create :concept_solution
    other_solution = create :concept_solution
    token = Solution::AssistantConversation::CreateConversationToken.(other_solution)

    refute Solution::AssistantConversation::VerifyConversationToken.(token, solution)
  end

  test "fails for an expired token" do
    solution = create :concept_solution
    token = travel_to(2.hours.ago) do
      Solution::AssistantConversation::CreateConversationToken.(solution)
    end

    refute Solution::AssistantConversation::VerifyConversationToken.(token, solution)
  end

  test "fails for a token signed with the wrong secret" do
    solution = create :concept_solution
    token = JWT.encode({ sub: solution.user_id, solution_uuid: solution.uuid }, "wrong-secret", 'HS256')

    refute Solution::AssistantConversation::VerifyConversationToken.(token, solution)
  end

  test "fails for garbage" do
    solution = create :concept_solution

    refute Solution::AssistantConversation::VerifyConversationToken.("garbage", solution)
    refute Solution::AssistantConversation::VerifyConversationToken.(nil, solution)
  end
end
