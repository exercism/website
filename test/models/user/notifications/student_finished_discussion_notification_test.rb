require 'test_helper'

class User::Notifications::StudentFinishedDiscussionNotificationTest < ActiveSupport::TestCase
  test "keys are valid" do
    student = create :user, handle: "student"
    mentor = create :user
    track = create :track, title: "Ruby"
    exercise = create(:concept_exercise, title: "Strings", track:)
    solution = create(:concept_solution, user: student, exercise:)
    discussion = create(:mentor_discussion, solution:, mentor:)

    notification = User::Notifications::StudentFinishedDiscussionNotification.create!(
      user: mentor,
      params: { discussion: }
    )

    assert_equal "#{mentor.id}|student_finished_discussion|Discussion##{discussion.id}", notification.uniqueness_key
    assert_equal "student has finished the discussion on the solution you are mentoring for Ruby:Strings", notification.text
    assert_equal :avatar, notification.image_type
    assert_equal student.avatar_url, notification.image_url
    assert_equal discussion.mentor_url, notification.url
    assert_equal "/mentoring/discussions/#{discussion.uuid}", notification.path
  end
end
