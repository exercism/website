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

  test "requires_mentor_action scopes" do
    requires_action = create :solution_mentor_discussion, requires_mentor_action_since: Time.current
    create :solution_mentor_discussion, requires_mentor_action_since: nil

    assert_equal [requires_action], Solution::MentorDiscussion.requires_mentor_action
  end

  test "requires_student_action scopes" do
    requires_action = create :solution_mentor_discussion, requires_student_action_since: Time.current
    create :solution_mentor_discussion, requires_student_action_since: nil

    assert_equal [requires_action], Solution::MentorDiscussion.requires_student_action
  end
end
