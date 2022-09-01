require "test_helper"

class User::UpdateMentorRolesTest < ActiveSupport::TestCase
  test "adds or removes supermentor role depending on criteria being met" do
    user = create :user, became_mentor_at: nil, roles: []

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
      create :mentor_discussion, :student_finished, mentor: user
    end

    # Too few finished mentoring sessions
    user.update(mentor_satisfaction_percentage: 95)
    User::UpdateMentorRoles.(user)
    refute user.reload.supermentor?

    # Only mentor discussions finished by student count
    create :mentor_discussion, :awaiting_mentor, mentor: user
    create :mentor_discussion, :awaiting_student, mentor: user
    create :mentor_discussion, :mentor_finished, mentor: user
    User::UpdateMentorRoles.(user)
    refute user.reload.supermentor?

    create :mentor_discussion, :student_finished, mentor: user
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
