require 'test_helper'

class User::ReplyToDiscussionTest < ActiveSupport::TestCase
  test "creates discussion post" do
    submission = create :submission
    content_markdown = "foobar"
    discussion = create :solution_mentor_discussion

    discussion_post = User::ReplyToDiscussion.(
      discussion,
      submission,
      content_markdown
    )
    assert discussion_post.persisted?
    assert_equal submission, discussion_post.submission
    assert_equal discussion, discussion_post.source
    assert_equal content_markdown, discussion_post.content_markdown
    assert_equal submission.solution.user, discussion_post.user
  end

  test "creates notification" do
    user = create :user
    solution = create :practice_solution, user: user
    submission = create :submission, solution: solution
    mentor = create :user
    discussion = create(:solution_mentor_discussion, solution: solution, mentor: mentor)

    User::ReplyToDiscussion.(
      discussion,
      submission,
      "foobar"
    )
    assert_equal 1, mentor.notifications.size
    notification = mentor.notifications.first
    assert_equal Notifications::StudentRepliedToDiscussionNotification, notification.class
    assert_equal({ discussion_post: Submission::DiscussionPost.first }, notification.send(:params))
  end
end
