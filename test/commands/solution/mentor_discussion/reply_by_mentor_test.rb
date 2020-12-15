require 'test_helper'

class Solution::MentorDiscussion::ReplyByMentorTest < ActiveSupport::TestCase
  test "creates discussion post" do
    iteration = create :iteration
    content_markdown = "foobar"
    mentor = create :user
    discussion = create :solution_mentor_discussion, mentor: mentor

    discussion_post = Solution::MentorDiscussion::ReplyByMentor.(
      discussion,
      iteration.idx,
      content_markdown
    )
    assert discussion_post.persisted?
    assert_equal iteration, discussion_post.iteration
    assert_equal discussion, discussion_post.discussion
    assert_equal content_markdown, discussion_post.content_markdown
    assert_equal mentor, discussion_post.author
  end

  test "creates notification" do
    user = create :user
    solution = create :practice_solution, user: user
    iteration = create :iteration, solution: solution
    discussion = create(:solution_mentor_discussion, solution: solution)

    Solution::MentorDiscussion::ReplyByMentor.(
      discussion,
      iteration.idx,
      "foobar"
    )
    assert_equal 1, user.notifications.size
    notification = Notification.where(user: user).first
    assert_equal Notifications::MentorRepliedToDiscussionNotification, notification.class
    assert_equal({ discussion_post: Solution::MentorDiscussionPost.first }, notification.send(:params))
  end
end
