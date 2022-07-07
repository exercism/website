require "test_helper"

class NotificationsMailerTest < ActionMailer::TestCase
  test "mentor_started_discussion" do
    student = create :user, handle: "handle-6b48cf20"
    mentor = create :user, handle: "handle-84a8e4a1"
    solution = create :practice_solution, user: student
    exercise = solution.exercise
    discussion = create :mentor_discussion, mentor: mentor, solution: solution, uuid: "d699426e31ca4ceaa953a9d3007526b0"
    notification = create :mentor_started_discussion_notification,
      status: :unread, user: student, params: { discussion: }

    email = NotificationsMailer.with(notification:).mentor_started_discussion
    subject = "#{mentor.handle} has started mentoring you on #{exercise.track.title}/#{exercise.title}"
    assert_email(email, student.email, subject, "mentor_started_discussion")
  end

  test "mentor_replied_to_discussion" do
    student = create :user, handle: "handle-6b48cf20"
    mentor = create :user, handle: "handle-84a8e4a1"
    solution = create :practice_solution, user: student
    exercise = solution.exercise
    discussion = create :mentor_discussion, mentor: mentor, solution: solution, uuid: "d699426e31ca4ceaa953a9d3007526b0"
    discussion_post = create :mentor_discussion_post, author: mentor, discussion: discussion
    notification = create :mentor_replied_to_discussion_notification,
      status: :unread, user: student, params: { discussion_post: }

    email = NotificationsMailer.with(notification:).mentor_replied_to_discussion
    subject = "#{mentor.handle} has commented in your discussion on #{exercise.track.title}/#{exercise.title}"
    assert_email(email, student.email, subject, "mentor_replied_to_discussion")
  end

  test "mentor_finished_discussion" do
    student = create :user, handle: "handle-6b48cf20"
    mentor = create :user, handle: "handle-84a8e4a1"
    solution = create :practice_solution, user: student
    exercise = solution.exercise
    discussion = create :mentor_discussion, mentor: mentor, solution: solution, uuid: "d699426e31ca4ceaa953a9d3007526b0"
    notification = create :mentor_finished_discussion_notification,
      status: :unread, user: student, params: { discussion: }

    email = NotificationsMailer.with(notification:).mentor_finished_discussion
    subject = "[Mentoring] #{mentor.handle} has ended your discussion on #{exercise.track.title}/#{exercise.title}"
    assert_email(email, student.email, subject, "mentor_finished_discussion")
  end

  test "student_replied_to_discussion" do
    student = create :user, handle: "handle-6b48cf20"
    mentor = create :user, handle: "handle-84a8e4a1"
    solution = create :practice_solution, user: student
    exercise = solution.exercise
    discussion = create :mentor_discussion, mentor: mentor, solution: solution, uuid: "d699426e31ca4ceaa953a9d3007526b0"
    discussion_post = create :mentor_discussion_post, author: student, discussion: discussion
    notification = create :student_replied_to_discussion_notification,
      status: :unread, user: mentor, params: { discussion_post: }

    email = NotificationsMailer.with(notification:).student_replied_to_discussion
    subject = "[Mentoring] #{student.handle} has commented in your discussion on #{exercise.track.title}/#{exercise.title}"
    assert_email(email, mentor.email, subject, "student_replied_to_discussion")
  end

  test "student_finished_discussion" do
    student = create :user, handle: "handle-6b48cf20"
    mentor = create :user, handle: "handle-84a8e4a1"
    solution = create :practice_solution, user: student
    exercise = solution.exercise
    discussion = create :mentor_discussion, mentor: mentor, solution: solution, uuid: "d699426e31ca4ceaa953a9d3007526b0"
    notification = create :student_finished_discussion_notification,
      status: :unread, user: mentor, params: { discussion: }

    email = NotificationsMailer.with(notification:).student_finished_discussion
    subject = "[Mentoring] #{student.handle} has ended your discussion on #{exercise.track.title}/#{exercise.title}" # rubocop:disable Layout/LineLength
    assert_email(email, mentor.email, subject, "student_finished_discussion")
  end

  test "acquired_badge" do
    user = create :user, handle: "someone-cool"
    acquired_badge = create :user_acquired_badge, user: user
    notification = create :acquired_badge_notification,
      status: :email_only, user: user, params: { user_acquired_badge: acquired_badge }

    email = NotificationsMailer.with(notification:).acquired_badge
    subject = "You've unlocked a new badge"
    assert_email(email, user.email, subject, "acquired_badge")
  end
end
