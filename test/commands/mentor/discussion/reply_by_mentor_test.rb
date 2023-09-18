require 'test_helper'

class Mentor::Discussion::ReplyByMentorTest < ActiveSupport::TestCase
  test "creates discussion post" do
    freeze_time do
      iteration = create :iteration
      content_markdown = "foobar"
      mentor = create :user
      discussion = create :mentor_discussion, mentor:, solution: iteration.solution

      discussion_post = Mentor::Discussion::ReplyByMentor.(
        discussion,
        iteration,
        content_markdown
      )
      assert discussion_post.persisted?
      assert_equal iteration, discussion_post.iteration
      assert_equal discussion, discussion_post.discussion
      assert_equal content_markdown, discussion_post.content_markdown
      assert_equal mentor, discussion_post.author
      assert discussion_post.seen_by_mentor?
      refute discussion_post.seen_by_student?

      assert_nil discussion.awaiting_mentor_since
      assert_equal Time.current, discussion.awaiting_student_since
    end
  end

  test "creates notification" do
    user = create :user
    solution = create(:practice_solution, user:)
    iteration = create(:iteration, solution:)
    discussion = create(:mentor_discussion, solution:)

    Mentor::Discussion::ReplyByMentor.(
      discussion,
      iteration,
      "foobar"
    )
    assert_equal 1, user.notifications.size
    notification = User::Notification.where(user:).first
    assert_instance_of User::Notifications::MentorRepliedToDiscussionNotification, notification
    assert_equal(
      { discussion_post: Mentor::DiscussionPost.first.to_global_id.to_s }.with_indifferent_access,
      notification.send(:params)
    )
  end

  test "sets mentor of submission representation" do
    iteration = create :iteration
    mentor = create :user
    discussion = create :mentor_discussion, mentor:, solution: iteration.solution
    submission_representation = create :submission_representation, submission: iteration.submission, mentored_by: nil

    perform_enqueued_jobs do
      Mentor::Discussion::ReplyByMentor.(discussion, iteration, "foobar")
    end

    assert_equal mentor, submission_representation.reload.mentored_by
  end
end
