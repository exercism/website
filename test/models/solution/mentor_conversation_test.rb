require 'test_helper'

class Solution::MentorConversationTest < ActiveSupport::TestCase
  test "solution set to request solution" do
    request = create :solution_mentor_request
    conversation = Solution::MentorConversation.create!(
      mentor: create(:user),
      request: request
    )
    assert_equal request.solution, conversation.solution
  end
end
