require "test_helper"

class Badge::PolyglotBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :polyglot_badge
    assert_equal "Polyglot", badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :'badge-polyglot', badge.icon
    assert_equal 'Completed and published 5 exercises in 12 languages in a single year', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    year = 2023
    user = create :user
    other_user = create :user
    badge = create :polyglot_badge

    refute badge.award_to?(user.reload)

    tracks = create_list(:track, 11, :random_slug).each do |track|
      create_list(:practice_exercise, 5, track:) do |exercise|
        create(:practice_solution, :published, user:, track:, exercise:,
          published_at: Time.utc(year, SecureRandom.random_number(1..12), SecureRandom.random_number(1..28)))
      end
    end

    refute badge.award_to?(user.reload)

    track = create :track, :random_slug
    create_list(:practice_exercise, 4, track:) do |exercise|
      create(:practice_solution, :published, user:, track:, exercise:,
        published_at: Time.utc(year, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    end

    refute badge.award_to?(user.reload)

    # Sanity check: published solution in different year is counted separately
    exercise = create(:practice_exercise, :random_slug, track:)
    create(:practice_solution, :published, user:, track:, exercise:,
      published_at: Time.utc(year - 1, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    refute badge.award_to?(user.reload)

    # Sanity check: one track exceeding minimum number of solutions does not count toward other track
    create_list(:practice_exercise, 15, track: tracks.first) do |track_exercise|
      create(:practice_solution, :published, user:, track:, exercise: track_exercise,
        published_at: Time.utc(year, SecureRandom.random_number(1..12), SecureRandom.random_number(1..28)))
    end
    refute badge.award_to?(user.reload)

    # Sanity check: published solution by other user is not counted
    exercise = create(:practice_exercise, :random_slug, track:)
    create(:practice_solution, :published, user: other_user, track:, exercise:,
      published_at: Time.utc(year, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))
    refute badge.award_to?(user.reload)

    exercise = create(:practice_exercise, :random_slug, track:)
    create(:practice_solution, :published, user:, track:, exercise:,
      published_at: Time.utc(year, SecureRandom.rand(1..12), SecureRandom.rand(1..28)))

    assert badge.award_to?(user.reload)
  end
end
