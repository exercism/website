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

  test "adds automator role if user and track combination in automators.json" do
    automators = [
      { "username": "ErikSchierboom", "tracks": %w[nim kotlin] }
    ]
    Git::WebsiteCopy.any_instance.stubs(:automators).returns(automators)

    ruby = create :track, slug: 'ruby'
    nim = create :track, slug: 'nim'
    kotlin = create :track, slug: 'kotlin'
    automator = create :user, handle: 'ErikSchierboom', roles: []
    non_automator = create :user, handle: 'iHiD', roles: []

    mentorship_automator_ruby = create(:user_track_mentorship, user: automator, track: ruby)
    mentorship_automator_nim = create(:user_track_mentorship, user: automator, track: nim)
    mentorship_automator_kotlin = create(:user_track_mentorship, user: automator, track: kotlin)

    mentorship_non_automator_ruby = create(:user_track_mentorship, user: non_automator, track: ruby)
    mentorship_non_automator_nim = create(:user_track_mentorship, user: non_automator, track: nim)
    mentorship_non_automator_kotlin = create(:user_track_mentorship, user: non_automator, track: kotlin)

    User::UpdateAutomatorRole.(automator, ruby)
    refute mentorship_automator_ruby.reload.automator?

    User::UpdateAutomatorRole.(automator, nim)
    assert mentorship_automator_nim.reload.automator?

    User::UpdateAutomatorRole.(automator, kotlin)
    assert mentorship_automator_kotlin.reload.automator?

    User::UpdateAutomatorRole.(non_automator, ruby)
    refute mentorship_non_automator_ruby.reload.automator?

    User::UpdateAutomatorRole.(non_automator, nim)
    refute mentorship_non_automator_nim.reload.automator?

    User::UpdateAutomatorRole.(non_automator, kotlin)
    refute mentorship_non_automator_kotlin.reload.automator?
  end

  test "adds automator role if user and track combination in automators.json is case-insensitive" do
    track = create :track, slug: 'ruby'
    user = create :user, handle: 'ErikSchierboom', roles: []
    mentorship = create(:user_track_mentorship, user:, track:)

    # Same casing
    automators = [{ "username": "ErikSchierboom", "tracks": ["ruby"] }]
    Git::WebsiteCopy.any_instance.stubs(:automators).returns(automators)
    User::UpdateAutomatorRole.(user, track)
    assert mentorship.reload.automator?

    # Different casing
    automators = [{ "username": "ERIKSCHIERBOOM", "tracks": ["RUBY"] }]
    Git::WebsiteCopy.any_instance.stubs(:automators).returns(automators)
    User::UpdateAutomatorRole.(user, track)
    assert mentorship.reload.automator?

    # Another casing difference
    automators = [{ "username": "ErIKSCHierBooM", "tracks": ["RuBy"] }]
    Git::WebsiteCopy.any_instance.stubs(:automators).returns(automators)
    User::UpdateAutomatorRole.(user, track)
    assert mentorship.reload.automator?
  end
end
