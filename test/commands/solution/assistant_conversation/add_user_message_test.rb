require "test_helper"

class Solution::AssistantConversation::AddUserMessageTest < ActiveSupport::TestCase
  test "appends the message to the conversation" do
    solution = create :concept_solution
    timestamp = Time.current.utc.iso8601(3)

    Solution::AssistantConversation::AddUserMessage.(solution, "How do I do this?", timestamp)

    conversation = solution.reload.assistant_conversation
    assert_equal(
      [{ "role" => "user", "content" => "How do I do this?", "timestamp" => timestamp }],
      conversation.messages
    )
  end

  test "appends to an existing conversation" do
    solution = create :concept_solution
    create(
      :solution_assistant_conversation,
      solution:,
      messages: [{ role: "user", content: "First", timestamp: "2026-07-17T00:00:00.000Z" }]
    )

    Solution::AssistantConversation::AddUserMessage.(solution, "Second", "2026-07-17T00:01:00.000Z")

    assert_equal(%w[First Second], solution.reload.assistant_conversation.messages.map { |m| m["content"] })
  end
end
