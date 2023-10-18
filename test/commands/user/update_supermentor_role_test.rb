require "test_helper"

class User::UpdateSupermentorRoleTest < ActiveSupport::TestCase
  test "adds or removes supermentor role depending on criteria being met" do
    track = create :track
    user = create :user, roles: []
    mentorship = create(:user_track_mentorship, user:, track:)

    User::UpdateSupermentorRole.(user)
    refute user.reload.supermentor? # Not yet a mentor

    # nil satisfacation
    user.update(cache: { 'mentor_satisfaction_percentage' => nil })
    mentorship.update(num_finished_discussions: 100)
    User::UpdateSupermentorRole.(user)
    refute user.reload.supermentor?

    # Satisfaction is too low
    user.update(cache: { 'mentor_satisfaction_percentage' => 94 })
    mentorship.update(num_finished_discussions: 100)
    User::UpdateSupermentorRole.(user)
    refute user.reload.supermentor?

    # Discussions are too low
    user.update(cache: { 'mentor_satisfaction_percentage' => 95 })
    mentorship.update(num_finished_discussions: 99)
    User::UpdateSupermentorRole.(user)
    refute user.reload.supermentor?

    # Not mentor
    user.update(cache: { 'mentor_satisfaction_percentage' => 95 })
    mentorship.update(num_finished_discussions: 100)
    user.update(became_mentor_at: nil)
    User::UpdateSupermentorRole.(user)
    refute user.reload.supermentor?

    # All is good!
    user.update(cache: { 'mentor_satisfaction_percentage' => 95 })
    mentorship.update(num_finished_discussions: 100)
    user.update(became_mentor_at: Time.current)
    User::UpdateSupermentorRole.(user)
    assert user.reload.supermentor?
  end

  test "awards supermentor badge when role is added" do
    track = create :track
    user = create :user
    mentorship = create(:user_track_mentorship, user:, track:)

    # Sanity check: role is not added so badge shouldn't be awarded
    User::UpdateSupermentorRole.(user)
    refute_includes user.reload.badges.map(&:class), Badges::SupermentorBadge

    user.update(cache: { 'mentor_satisfaction_percentage' => 95 })
    mentorship.update(num_finished_discussions: 100)

    perform_enqueued_jobs do
      User::UpdateSupermentorRole.(user)
    end
    assert_includes user.reload.badges.map(&:class), Badges::SupermentorBadge

    # Sanity check: losing role does not result in losing badge
    user.update(cache: { 'mentor_satisfaction_percentage' => 0 })
    mentorship.update(num_finished_discussions: 0)
    perform_enqueued_jobs do
      User::UpdateSupermentorRole.(user)
    end

    assert_includes user.reload.badges.map(&:class), Badges::SupermentorBadge
  end
end
