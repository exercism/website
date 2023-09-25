require 'test_helper'

class Mentor::Discussion::UpdateTimedOutTest < ActiveSupport::TestCase
  [1, 13, 26].each do |num_days_waiting|
    test "do not time out when awaiting student for #{num_days_waiting} days" do
      mentor = create :user
      student = create :user
      discussion = create(:mentor_discussion, :awaiting_student, awaiting_student_since: Time.now.utc - num_days_waiting.days,
        mentor:, student:)

      Mentor::Discussion::UpdateTimedOut.()

      assert_equal :awaiting_student, discussion.status
    end

    test "do not time out when awaiting mentor for #{num_days_waiting} days" do
      mentor = create :user
      student = create :user
      discussion = create(:mentor_discussion, :awaiting_mentor, awaiting_mentor_since: Time.now.utc - num_days_waiting.days, mentor:,
        student:)

      Mentor::Discussion::UpdateTimedOut.()

      assert_equal :awaiting_mentor, discussion.reload.status
    end
  end

  test "time out when awaiting student for 28 days" do
    mentor = create :user
    student = create :user
    discussion = create(:mentor_discussion, :awaiting_student, awaiting_student_since: Time.now.utc - 28.days - 5.seconds,
      mentor:, student:)

    Mentor::Discussion::UpdateTimedOut.()

    assert_equal :student_timed_out, discussion.reload.status
  end

  test "time out when awaiting mentor for 28 days" do
    mentor = create :user
    student = create :user
    discussion = create(:mentor_discussion, :awaiting_mentor, awaiting_mentor_since: Time.now.utc - 28.days - 5.seconds,
      mentor:, student:)

    Mentor::Discussion::UpdateTimedOut.()

    assert_equal :mentor_timed_out, discussion.reload.status
  end

  test "create notifications when student timed out" do
    mentor = create :user
    student = create :user
    discussion = create(:mentor_discussion, :awaiting_student, awaiting_student_since: Time.now.utc - 28.days - 5.seconds,
      mentor:, student:)

    Mentor::Discussion::UpdateTimedOut.()

    assert_equal 1, mentor.notifications.size
    assert_equal 1, student.notifications.size
    student_notification = student.notifications.first
    mentor_notification = mentor.notifications.first
    assert_instance_of User::Notifications::StudentTimedOutDiscussionStudentNotification, student_notification
    assert_instance_of User::Notifications::StudentTimedOutDiscussionMentorNotification, mentor_notification
    expected_params = { discussion: discussion.to_global_id.to_s }.with_indifferent_access
    assert_equal expected_params, student_notification.send(:params)
    assert_equal expected_params, mentor_notification.send(:params)
  end

  test "create notifications when mentor timed out" do
    mentor = create :user
    student = create :user
    discussion = create(:mentor_discussion, :awaiting_mentor, awaiting_mentor_since: Time.now.utc - 28.days - 5.seconds,
      mentor:, student:)

    Mentor::Discussion::UpdateTimedOut.()

    assert_equal 1, mentor.notifications.size
    assert_equal 1, student.notifications.size
    student_notification = student.notifications.first
    mentor_notification = mentor.notifications.first
    assert_instance_of User::Notifications::MentorTimedOutDiscussionStudentNotification, student_notification
    assert_instance_of User::Notifications::MentorTimedOutDiscussionMentorNotification, mentor_notification
    expected_params = { discussion: discussion.to_global_id.to_s }.with_indifferent_access
    assert_equal expected_params, student_notification.send(:params)
    assert_equal expected_params, mentor_notification.send(:params)
  end
end
