require "test_helper"

class User::UpdateMentorRolesTest < ActiveSupport::TestCase
  test "adds or removes supermentor role depending on criteria being met" do
    track = create :track
    user = create :user, became_mentor_at: nil, roles: []
    create :user_track_mentorship, user: user, track: track

    User::UpdateMentorRoles.(user)
    refute user.reload.supermentor? # Not yet a mentor

    user.update(became_mentor_at: Time.current)
    User::UpdateMentorRoles.(user)
    refute user.reload.supermentor? # Mentor but criteria not met

    # Num finished mentoring sessions and satisfaction percentage are too low
    user.update(mentor_satisfaction_percentage: 94)
    User::UpdateMentorRoles.(user)
    refute user.reload.supermentor?

    99.times do
      create :mentor_discussion, :student_finished, rating: :great, mentor: user, track:
    end

    # Too few finished mentoring sessions
    perform_enqueued_jobs
    User::UpdateMentorRoles.(user)
    refute user.reload.supermentor?

    # Only mentor discussions finished by student count
    create :mentor_discussion, :awaiting_mentor, mentor: user, track: track
    create :mentor_discussion, :awaiting_student, mentor: user, track: track
    create :mentor_discussion, :mentor_finished, mentor: user, track: track
    perform_enqueued_jobs
    User::UpdateMentorRoles.(user)
    refute user.reload.supermentor?

    create :mentor_discussion, :student_finished, rating: :great, mentor: user, track: track
    perform_enqueued_jobs
    User::UpdateMentorRoles.(user)
    assert user.reload.supermentor?

    # Satisfaction percentage is not set
    user.update(mentor_satisfaction_percentage: nil)
    User::UpdateMentorRoles.(user)
    refute user.reload.supermentor?

    # Satisfaction percentage is too low
    user.update(mentor_satisfaction_percentage: 94)
    User::UpdateMentorRoles.(user)
    refute user.reload.supermentor?
  end
end
