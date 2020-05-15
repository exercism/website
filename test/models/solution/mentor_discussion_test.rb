require 'test_helper'

class Solution::MentorDiscussionTest < ActiveSupport::TestCase
  test "solution set to request solution" do
    request = create :solution_mentor_request
    discussion = Solution::MentorDiscussion.create!(
      mentor: create(:user),
      request: request
    )
    assert_equal request.solution, discussion.solution
  end
end
