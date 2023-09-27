require "test_helper"

class User::UpdateAutomatorRoleTest < ActiveSupport::TestCase
  test "adds automator role if appropriate" do
    track = create :track
    user = create :user, roles: []
    mentorship = create(:user_track_mentorship, user:, track:)

    User::UpdateAutomatorRole.(user, track)
    refute mentorship.reload.automator? # Not yet a mentor

    # nil satisfacation
    user.update(cache: { 'mentor_satisfaction_percentage' => nil })
    mentorship.update(num_finished_discussions: 100)
    User::UpdateAutomatorRole.(user, track)
    refute mentorship.reload.automator?

    # Satisfaction is too low
    user.update(cache: { 'mentor_satisfaction_percentage' => 94 })
    mentorship.update(num_finished_discussions: 100)
    User::UpdateAutomatorRole.(user, track)
    refute mentorship.reload.automator?

    # Discussions are too low
    user.update(cache: { 'mentor_satisfaction_percentage' => 95 })
    mentorship.update(num_finished_discussions: 99)
    User::UpdateAutomatorRole.(user, track)
    refute mentorship.reload.automator?

    # Not mentor
    user.update(cache: { 'mentor_satisfaction_percentage' => 95 })
    mentorship.update(num_finished_discussions: 99)
    user.update(became_mentor_at: nil)
    User::UpdateAutomatorRole.(user, track)
    refute mentorship.reload.automator?

    # All is good!
    user.update(became_mentor_at: Time.current)
    user.update(cache: { 'mentor_satisfaction_percentage' => 95 })
    mentorship.update(num_finished_discussions: 100)
    User::UpdateAutomatorRole.(user, track)
    assert mentorship.reload.automator?
  end
end
