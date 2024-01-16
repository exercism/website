require "test_helper"

class Badges::SlimlineSeptemberBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :slimline_september_badge
    assert_equal "Slimline September", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'badge-slimline-september', badge.icon
    assert_equal 'Completed and published five exercises in a concise language in September', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :slimline_september_badge
    jq = create :track, slug: 'jq'
    csharp = create :track, slug: 'csharp'

    # No solutions
    refute badge.award_to?(user.reload)

    # hello world doesn't count
    exercise = create :practice_exercise, slug: 'hello-world', track: jq
    create :practice_solution, :published, user:, track: jq, exercise:, published_at: Time.utc(2023, 9, 1)
    refute badge.award_to?(user.reload)

    # 4 bob's is not enough
    4.times do |idx|
      exercise = create :practice_exercise, slug: 'bob', track: jq
      create :practice_solution, :published, user:, track: jq, exercise:, published_at: Time.utc(2023, 9, idx + 5)
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th exercise in csharp
    another_exercise = create :practice_exercise, slug: 'leap', track: csharp
    create :practice_solution, :published, user:, track: csharp, exercise: another_exercise, published_at: Time.utc(2023, 9, 6)
    refute badge.award_to?(user.reload)

    # Iterate a 5th bob, but in August
    exercise = create :practice_exercise, slug: 'bob', track: jq
    solution = create :practice_solution, :published, user:, track: jq, exercise:,
      published_at: Time.utc(2023, 8, 20)
    refute badge.award_to?(user.reload)

    # Complete it
    solution.update(completed_at: Time.utc(2023, 9, 27))
    refute badge.award_to?(user.reload)

    # Publish it
    solution.update(published_at: Time.utc(2023, 9, 28))
    assert badge.award_to?(user.reload)
  end

  test "last day of August" do
    user = create :user
    badge = create :slimline_september_badge
    track = create :track, slug: 'jq'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 8, 31)
    end
    assert badge.award_to?(user.reload)
  end

  test "any day of September" do
    user = create :user
    badge = create :slimline_september_badge
    track = create :track, slug: 'jq'

    [1, 7, 14, 25, 30].each do |day|
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 9, day)
    end

    assert badge.award_to?(user.reload)
  end

  test "first day of October" do
    user = create :user
    badge = create :slimline_september_badge
    track = create :track, slug: 'jq'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 10, 1)
    end

    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    jq = create :track, slug: 'jq'
    csharp = create :track, slug: 'csharp'
    assert Badges::SlimlineSeptemberBadge.worth_queuing?(exercise: create(:practice_exercise, track: jq))
    refute Badges::SlimlineSeptemberBadge.worth_queuing?(exercise: create(:practice_exercise, track: jq, slug: 'hello-world'))
    refute Badges::SlimlineSeptemberBadge.worth_queuing?(exercise: create(:practice_exercise, track: csharp))
  end
end
