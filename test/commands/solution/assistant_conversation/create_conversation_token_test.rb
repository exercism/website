require "test_helper"

class Solution::AssistantConversation::CreateConversationTokenTest < ActiveSupport::TestCase
  setup do
    Exercism.secrets.assistant_chat_jwt_secret = "test-assistant-jwt-secret"
  end

  test "returns a signed JWT with the expected claims" do
    freeze_time do
      solution = create :concept_solution

      token = Solution::AssistantConversation::CreateConversationToken.(solution)

      payload, header = JWT.decode(token, Exercism.secrets.assistant_chat_jwt_secret, true, { algorithm: 'HS256' })
      assert_equal "HS256", header["alg"]
      assert_equal solution.user_id, payload["sub"]
      assert_equal solution.uuid, payload["solution_uuid"]
      assert_equal solution.track.slug, payload["track_slug"]
      assert_equal solution.exercise.slug, payload["exercise_slug"]
      assert_equal 1.hour.from_now.to_i, payload["exp"]
      assert_equal Time.current.to_i, payload["iat"]
    end
  end

  test "creates the conversation record" do
    solution = create :concept_solution

    assert_difference -> { Solution::AssistantConversation.count }, 1 do
      Solution::AssistantConversation::CreateConversationToken.(solution)
    end

    conversation = Solution::AssistantConversation.last
    assert_equal solution, conversation.solution
    assert_equal solution.user, conversation.user
  end

  test "raises when access is denied" do
    user = create :user
    create(:solution_assistant_conversation, solution: create(:practice_solution, user:))
    solution = create(:concept_solution, user:)

    assert_raises AssistantConversationAccessDeniedError do
      Solution::AssistantConversation::CreateConversationToken.(solution)
    end
  end
end
