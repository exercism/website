require 'test_helper'

class User::ReplyToDiscussionTest < ActiveSupport::TestCase
  test "creates discussion post" do
    iteration = create :iteration
    content_markdown = "foobar"
    discussion = create :solution_mentor_discussion

    discussion_post = User::ReplyToDiscussion.(
      discussion,
      iteration, 
      content_markdown
    )
    assert discussion_post.persisted?
    assert_equal iteration, discussion_post.iteration
    assert_equal discussion, discussion_post.source
    assert_equal content_markdown, discussion_post.content_markdown
    assert_equal iteration.solution.user, discussion_post.user
  end

  test "creates notification" do
    user = create :user
    solution = create :practice_solution, user: user
    iteration = create :iteration, solution: solution
    mentor = create :user
    discussion = create(:solution_mentor_discussion, solution: solution, mentor: mentor)

    User::ReplyToDiscussion.(
      discussion,
      iteration,
      "foobar"
    )
    assert_equal 1, mentor.notifications.size
    notification = mentor.notifications.first
    assert_equal Notification::StudentRepliedToDiscussionNotification, notification.class
    assert_equal({discussion_post: Iteration::DiscussionPost.first}, notification.send(:params))
  end
end


