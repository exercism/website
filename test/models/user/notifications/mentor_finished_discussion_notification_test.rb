require 'test_helper'

class User::Notifications::MentorFinishedDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    mentor = create :user, handle: "mentor"
    student = create :user
    track = create :track, title: "Ruby"
    exercise = create(:concept_exercise, title: "Strings", track:)
    solution = create(:concept_solution, user: student, exercise:)
    discussion = create(:mentor_discussion, solution:, mentor:)

    notification = User::Notifications::MentorFinishedDiscussionNotification.create!(
      user: student,
      params: { discussion: }
    )

    assert_equal "#{student.id}|mentor_finished_discussion|Discussion##{discussion.id}", notification.uniqueness_key
    assert_equal "mentor has finished the discussion on your solution for Ruby:Strings", notification.text
    assert_equal :avatar, notification.image_type
    assert_equal mentor.avatar_url, notification.image_url
    assert_equal discussion.student_url, notification.url
    assert_equal(
      "/tracks/#{track.slug}/exercises/#{exercise.slug}/mentor_discussions/#{discussion.uuid}",
      notification.path
    )
  end
end
