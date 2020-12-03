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

  test "completed and in_progress scopes" do
    in_progress = create :solution_mentor_discussion, completed_at: nil
    completed = create :solution_mentor_discussion, completed_at: Time.current

    assert_equal [in_progress], Solution::MentorDiscussion.in_progress
    assert_equal [completed], Solution::MentorDiscussion.completed
  end
end
