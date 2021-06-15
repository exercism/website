require "test_helper"

class NotificationsMailerTest < ActionMailer::TestCase
  test "mentor_started_discussion" do
    user = create :user, handle: "handle-6b48cf20"
    mentor = create :user, handle: "handle-84a8e4a1"
    discussion = create :mentor_discussion, mentor: mentor, uuid: "d699426e31ca4ceaa953a9d3007526b0"
    exercise = discussion.exercise
    notification = create :mentor_started_discussion_notification, status: :unread, user: user,
                                                                   params: { discussion: discussion }

    email = NotificationsMailer.with(notification: notification).mentor_started_discussion
    subject = "#{discussion.mentor.handle} has started mentoring you on #{exercise.track.title}/#{exercise.title}"
    assert_email(email, user.email, subject, "mentor_started_discussion")
  end
end
