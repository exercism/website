require 'test_helper'

class Mentor::Discussion::SendNudgesTest < ActiveSupport::TestCase
  %i[awaiting_mentor mentor_finished finished].each do |status|
    test "do not send student nudge when status is #{status}" do
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
    test "send student nudge when awaiting for student for #{num_days_waiting} days" do
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

  test "only send student nudge within one day of cutoff date" do
    freeze_time do
      num_days_waiting = 7
      mentor = create :user
      student = create :user

      discussion_within_cutoff_1 = create(:mentor_discussion, :awaiting_student, mentor:, student:,
        awaiting_student_since: Time.now.utc - num_days_waiting.days - 1.hour)
      discussion_within_cutoff_2 = create(:mentor_discussion, :awaiting_student, mentor:, student:,
        awaiting_student_since: Time.now.utc - num_days_waiting.days - 23.hours)
      discussion_before_cutoff = create(:mentor_discussion, :awaiting_student, mentor:, student:,
        awaiting_student_since: Time.now.utc - num_days_waiting.days + 1.hour)
      discussion_after_cutoff = create(:mentor_discussion, :awaiting_student, mentor:, student:,
        awaiting_student_since: Time.now.utc - num_days_waiting.days - 25.hours)

      Mentor::Discussion::NudgeStudent.expects(:call).with(discussion_within_cutoff_1, num_days_waiting).once
      Mentor::Discussion::NudgeStudent.expects(:call).with(discussion_within_cutoff_2, num_days_waiting).once
      Mentor::Discussion::NudgeStudent.expects(:call).with(discussion_before_cutoff, num_days_waiting).never
      Mentor::Discussion::NudgeStudent.expects(:call).with(discussion_after_cutoff, num_days_waiting).never

      Mentor::Discussion::SendNudges.()
    end
  end

  test "don't create multiple student notifications for same nudge date" do
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

  test "send student nudge when awaiting_student_since progresses" do
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

  %i[awaiting_student mentor_finished finished].each do |status|
    test "do not send mentor nudge when status is #{status}" do
      freeze_time do
        mentor = create :user
        student = create :user
        create(:mentor_discussion, status:, mentor:, student:)

        Mentor::Discussion::SendNudges.()

        assert_empty student.notifications
        assert_empty mentor.notifications
      end
    end
  end

  [7, 14, 21].each do |num_days_waiting|
    test "send mentor nudge when awaiting for mentor for #{num_days_waiting} days" do
      mentor = create :user
      student = create :user
      discussion = create(:mentor_discussion, :awaiting_mentor, awaiting_mentor_since: Time.now.utc - num_days_waiting.days, mentor:,
        student:)

      Mentor::Discussion::SendNudges.()

      assert_empty student.notifications
      assert_equal 1, mentor.notifications.size
      notification = mentor.notifications.first
      assert_instance_of User::Notifications::NudgeMentorToReplyInDiscussionNotification, notification
      expected_params = { discussion: discussion.to_global_id.to_s, num_days_waiting: }.with_indifferent_access
      assert_equal expected_params, notification.send(:params)
    end
  end

  test "don't create multiple mentor notifications for same nudge date" do
    num_days_waiting = 7
    mentor = create :user
    student = create :user
    discussion = create(:mentor_discussion, :awaiting_mentor, awaiting_mentor_since: Time.now.utc - num_days_waiting.days, mentor:,
      student:)

    Mentor::Discussion::SendNudges.()
    Mentor::Discussion::SendNudges.()
    Mentor::Discussion::SendNudges.()

    assert_empty student.notifications
    assert_equal 1, mentor.notifications.size
    notification = mentor.notifications.first
    assert_instance_of User::Notifications::NudgeMentorToReplyInDiscussionNotification, notification
    expected_params = { discussion: discussion.to_global_id.to_s, num_days_waiting: }.with_indifferent_access
    assert_equal expected_params, notification.send(:params)
  end

  test "send mentor nudge when awaiting_mentor_since progresses" do
    num_days_waiting = 7
    mentor = create :user
    student = create :user
    discussion = create(:mentor_discussion, :awaiting_mentor, awaiting_mentor_since: Time.now.utc - num_days_waiting.days, mentor:,
      student:)

    Mentor::Discussion::SendNudges.()

    assert_empty student.notifications
    assert_equal 1, mentor.notifications.size
    notification = mentor.notifications.first
    assert_instance_of User::Notifications::NudgeMentorToReplyInDiscussionNotification, notification
    expected_params = { discussion: discussion.to_global_id.to_s, num_days_waiting: }.with_indifferent_access
    assert_equal expected_params, notification.send(:params)

    discussion.update(awaiting_mentor_since: Time.now.utc)
    travel_to(Time.now.utc + 15.days)

    Mentor::Discussion::SendNudges.()

    assert_empty student.notifications
    assert_equal 2, mentor.reload.notifications.size

    first_notification = mentor.notifications.first
    assert_instance_of User::Notifications::NudgeMentorToReplyInDiscussionNotification, first_notification
    expected_params = { discussion: discussion.to_global_id.to_s, num_days_waiting: 7 }.with_indifferent_access
    assert_equal expected_params, first_notification.send(:params)

    second_notification = mentor.notifications.second
    assert_instance_of User::Notifications::NudgeMentorToReplyInDiscussionNotification, second_notification
    expected_params = { discussion: discussion.to_global_id.to_s, num_days_waiting: 14 }.with_indifferent_access
    assert_equal expected_params, second_notification.send(:params)
  end

  test "gracefully handle errors when sending nudge" do
    mentor = create :user
    student = create :user
    discussion_1 = create(:mentor_discussion, :awaiting_mentor, awaiting_mentor_since: Time.now.utc - 7.days, mentor:,
      student:)
    discussion_2 = create(:mentor_discussion, :awaiting_student, awaiting_student_since: Time.now.utc - 7.days, mentor:,
      student:)
    discussion_3 = create(:mentor_discussion, :awaiting_mentor, awaiting_mentor_since: Time.now.utc - 14.days, mentor:,
      student:)
    discussion_4 = create(:mentor_discussion, :awaiting_student, awaiting_student_since: Time.now.utc - 21.days, mentor:,
      student:)

    User::Notification::Create.expects(:call).with(
      discussion_1.mentor,
      :nudge_mentor_to_reply_in_discussion,
      discussion: discussion_1,
      num_days_waiting: 7
    ).raises

    User::Notification::Create.expects(:call).with(
      discussion_2.student,
      :nudge_student_to_reply_in_discussion,
      discussion: discussion_2,
      num_days_waiting: 7
    ).raises

    User::Notification::Create.expects(:call).with(
      discussion_3.mentor,
      :nudge_mentor_to_reply_in_discussion,
      discussion: discussion_3,
      num_days_waiting: 14
    )

    User::Notification::Create.expects(:call).with(
      discussion_4.student,
      :nudge_student_to_reply_in_discussion,
      discussion: discussion_4,
      num_days_waiting: 21
    )

    Mentor::Discussion::SendNudges.()
  end
end
