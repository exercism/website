require 'test_helper'

class Mentor::Discussion::ReplyByStudentTest < ActiveSupport::TestCase
  test "creates discussion post" do
    freeze_time do
      iteration = create :iteration
      content_markdown = "foobar"
      discussion = create :mentor_discussion, solution: iteration.solution

      discussion_post = Mentor::Discussion::ReplyByStudent.(
        discussion,
        iteration,
        content_markdown
      )
      assert discussion_post.persisted?
      assert_equal iteration, discussion_post.iteration
      assert_equal discussion, discussion_post.discussion
      assert_equal content_markdown, discussion_post.content_markdown
      assert_equal iteration.solution.user, discussion_post.author
      assert discussion_post.seen_by_student?
      refute discussion_post.seen_by_mentor?

      assert_equal Time.current, discussion.awaiting_mentor_since
      assert_nil discussion.awaiting_student_since
    end
  end

  test "creates notification" do
    user = create :user
    solution = create(:practice_solution, user:)
    iteration = create(:iteration, solution:)
    mentor = create :user
    discussion = create(:mentor_discussion, solution:, mentor:)

    Mentor::Discussion::ReplyByStudent.(
      discussion,
      iteration,
      "foobar"
    )
    assert_equal 1, mentor.notifications.size
    notification = User::Notification.where(user: mentor).first
    assert_instance_of User::Notifications::StudentRepliedToDiscussionNotification, notification
    assert_equal(
      { discussion_post: Mentor::DiscussionPost.first.to_global_id.to_s }.with_indifferent_access,
      notification.send(:params)
    )
  end
end
