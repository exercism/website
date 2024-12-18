require "test_helper"

class Badge::ParticipantIn12In23BadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :participant_in_48_in_24_badge
    assert_equal "#48in24 Participant", badge.name
    assert_equal :common, badge.rarity
    assert_equal :'48in24', badge.icon
    assert_equal 'Participated in the #48in24 challenge and achieved a medal', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    badge = create :participant_in_48_in_24_badge
    exercises = User::Challenges::FeaturedExercisesProgress48In24.EXERCISES
    week1_slug = 'leap'
    user = create :user

    # No solutions
    refute badge.award_to?(user.reload)

    create :user_challenge, user:, challenge_id: '48in24'
    refute badge.award_to?(user.reload)

    # One exercise before 2024 does not qualify
    exercise = create(:practice_exercise, track: track[:csharp], slug: week1_slug)
    create(:practice_solution, :published, user:, track: track[:csharp], exercise:,
      published_at: Time.utc(2023, 12, 30))
    refute badge.award_to?(user.reload)

    # One exercise after 2024 does not qualify
    exercise = create(:practice_exercise, track: track[:tcl], slug: week1_slug)
    create(:practice_solution, :published, user:, track: track[:tcl], exercise:,
      published_at: Time.utc(2025, 1, 2))
    refute badge.award_to?(user.reload)

    # One exercise in 2024 for a non-featured exercise does not qualify
    exercise = create(:practice_exercise, track: track[:wren], slug: 'hello-world')
    create(:practice_solution, :published, user:, track: track[:wren], exercise:,
      published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    refute badge.award_to?(user.reload)

    # One exercise in 2024
    exercise = create(:practice_exercise, track: track[:wren], slug: week1_slug)
    create(:practice_solution, :published, user:, track: track[:wren], exercise:,
      published_at: Time.utc(2024, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    assert badge.award_to?(user.reload)

    # One exercise on Dec 31, 2023
    user2 = create :user
    create :user_challenge, user: user2, challenge_id: '48in24'
    exercise = create(:practice_exercise, track: track[:csharp], slug: week1_slug)
    create(:practice_solution, :published, user: user2, track: track[:csharp], exercise:,
      published_at: Time.utc(2023, 12, 31))
    assert badge.award_to?(user2.reload)

    # One exercise on Jan 1, 2025
    user3 = create :user
    create :user_challenge, user: user3, challenge_id: '48in24'
    exercise = create(:practice_exercise, track: track[:csharp], slug: week1_slug)
    create(:practice_solution, :published, user: user3, track: track[:csharp], exercise:,
      published_at: Time.utc(2025, 1, 1))
    assert badge.award_to?(user3.reload)
  end
end
