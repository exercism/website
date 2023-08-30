require 'test_helper'

class Mentor::Discussion::SendNudgesTest < ActiveSupport::TestCase
  %i[awaiting_mentor mentor_finished finished].each do |status|
    test "does not send student nudge when status is #{status}" do
      freeze_time do
        mentor = create :user
        student = create :user
        create(:mentor_discussion, status:, mentor:, student:)

        Mentor::Discussion::SendNudges.()

        assert_empty mentor.notifications
        assert_empty student.notifications
      end
    end
  end

  [7, 14, 21].each do |num_days_waiting|
    test "sends nudge when awaiting for student for #{num_days_waiting} days" do
      mentor = create :user
      student = create :user
      discussion = create(:mentor_discussion, :awaiting_student, awaiting_student_since: Time.now.utc - num_days_waiting.days, mentor:,
        student:)

      Mentor::Discussion::SendNudges.()

      assert_empty mentor.notifications
      assert_equal 1, student.notifications.size
      notification = student.notifications.first
      assert_instance_of User::Notifications::NudgeStudentToReplyInDiscussionNotification, notification
      expected_params = { discussion: discussion.to_global_id.to_s, num_days_waiting: }.with_indifferent_access
      assert_equal expected_params, notification.send(:params)
    end
  end

  test "don't create multiple notifications for same nudge date" do
    num_days_waiting = 7
    mentor = create :user
    student = create :user
    discussion = create(:mentor_discussion, :awaiting_student, awaiting_student_since: Time.now.utc - num_days_waiting.days, mentor:,
      student:)

    Mentor::Discussion::SendNudges.()
    Mentor::Discussion::SendNudges.()
    Mentor::Discussion::SendNudges.()

    assert_empty mentor.notifications
    assert_equal 1, student.notifications.size
    notification = student.notifications.first
    assert_instance_of User::Notifications::NudgeStudentToReplyInDiscussionNotification, notification
    expected_params = { discussion: discussion.to_global_id.to_s, num_days_waiting: }.with_indifferent_access
    assert_equal expected_params, notification.send(:params)
  end

  test "send nudge each time awaiting_student_since progresses" do
    num_days_waiting = 7
    mentor = create :user
    student = create :user
    discussion = create(:mentor_discussion, :awaiting_student, awaiting_student_since: Time.now.utc - num_days_waiting.days, mentor:,
      student:)

    Mentor::Discussion::SendNudges.()

    assert_empty mentor.notifications
    assert_equal 1, student.notifications.size
    notification = student.notifications.first
    assert_instance_of User::Notifications::NudgeStudentToReplyInDiscussionNotification, notification
    expected_params = { discussion: discussion.to_global_id.to_s, num_days_waiting: }.with_indifferent_access
    assert_equal expected_params, notification.send(:params)

    discussion.update(awaiting_student_since: Time.now.utc)
    travel_to(Time.now.utc + 15.days)

    Mentor::Discussion::SendNudges.()

    assert_empty mentor.notifications
    assert_equal 2, student.reload.notifications.size

    first_notification = student.notifications.first
    assert_instance_of User::Notifications::NudgeStudentToReplyInDiscussionNotification, first_notification
    expected_params = { discussion: discussion.to_global_id.to_s, num_days_waiting: 7 }.with_indifferent_access
    assert_equal expected_params, first_notification.send(:params)

    second_notification = student.notifications.second
    assert_instance_of User::Notifications::NudgeStudentToReplyInDiscussionNotification, second_notification
    expected_params = { discussion: discussion.to_global_id.to_s, num_days_waiting: 14 }.with_indifferent_access
    assert_equal expected_params, second_notification.send(:params)
  end
end
