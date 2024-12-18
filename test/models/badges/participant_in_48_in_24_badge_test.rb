require "test_helper"

class Badge::ParticipantIn48In24BadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :participant_in_48_in_24_badge
    assert_equal "#48in24 Participant", badge.name
    assert_equal :common, badge.rarity
    assert_equal :'48_in_24', badge.icon
    assert_equal 'Participated in the #48in24 challenge and achieved a medal', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    badge = create :participant_in_48_in_24_badge
    tracks = {}
    leap = {}

    %i[csharp tcl wren].each do |t|
      tracks[t] = create(:track, slug: t.to_s)
      leap[t] = create(:practice_exercise, track: tracks[t], slug: 'leap')
    end
    user = create :user

    # No solutions
    refute badge.award_to?(user.reload)

    create :user_challenge, user:, challenge_id: '48in24'
    refute badge.award_to?(user.reload)

    # One exercise before 2024 does not qualify
    create(:practice_solution, :published, user:,
      track: tracks[:csharp], exercise: leap[:csharp],
      published_at: Time.utc(2023, 12, 30))
    refute badge.award_to?(user.reload)

    # One exercise after 2024 does not qualify
    create(:practice_solution, :published, user:,
      track: tracks[:tcl], exercise: leap[:tcl],
      published_at: Time.utc(2025, 1, 2))
    refute badge.award_to?(user.reload)

    # One exercise in 2024 for a non-featured exercise does not qualify
    create(:practice_solution, :published, user:,
      track: tracks[:wren],
      exercise: create(:practice_exercise, track: tracks[:wren], slug: 'hello-world'),
      published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    refute badge.award_to?(user.reload)

    # One exercise in 2024
    create(:practice_solution, :published, user:,
      track: tracks[:wren], exercise: leap[:wren],
      published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    assert badge.award_to?(user.reload)

    # One exercise on Dec 31, 2023
    user_2 = create :user
    create :user_challenge, user: user_2, challenge_id: '48in24'
    create(:practice_solution, :published, user: user_2,
      track: tracks[:csharp], exercise: leap[:csharp],
      published_at: Time.utc(2023, 12, 31))
    assert badge.award_to?(user_2.reload)

    # One exercise on Jan 1, 2025
    user_3 = create :user
    create :user_challenge, user: user_3, challenge_id: '48in24'
    create(:practice_solution, :published, user: user_3,
      track: tracks[:csharp], exercise: leap[:csharp],
      published_at: Time.utc(2025, 1, 1))
    assert badge.award_to?(user_3.reload)
  end
end
