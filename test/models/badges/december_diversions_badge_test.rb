require "test_helper"

class Badges::DecemberDiversionsBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :december_diversions_badge
    assert_equal "December Diversions", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'badge-december-diversions', badge.icon
    assert_equal 'Completed and published five exercises in a December Diversions language', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :december_diversions_badge
    wren = create :track, slug: 'wren'
    csharp = create :track, slug: 'csharp'

    # No solutions
    refute badge.award_to?(user.reload)

    # hello world doesn't count
    exercise = create :practice_exercise, slug: 'hello-world', track: wren
    create :practice_solution, :published, user:, track: wren, exercise:, published_at: Time.utc(2023, 12, 1)
    refute badge.award_to?(user.reload)

    # 4 bob's is not enough
    4.times do |idx|
      exercise = create :practice_exercise, slug: 'bob', track: wren
      create :practice_solution, :published, user:, track: wren, exercise:, published_at: Time.utc(2023, 12, idx + 5)
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th exercise in csharp
    another_exercise = create :practice_exercise, slug: 'leap', track: csharp
    create :practice_solution, :published, user:, track: csharp, exercise: another_exercise, published_at: Time.utc(2023, 12, 6)
    refute badge.award_to?(user.reload)

    # Iterate a 5th bob, but in November
    exercise = create :practice_exercise, slug: 'bob', track: wren
    solution = create :practice_solution, :published, user:, track: wren, exercise:,
      published_at: Time.utc(2023, 11, 20)
    refute badge.award_to?(user.reload)

    # Complete it
    solution.update(completed_at: Time.utc(2023, 12, 27))
    refute badge.award_to?(user.reload)

    # Publish it
    solution.update(published_at: Time.utc(2023, 12, 28))
    assert badge.award_to?(user.reload)
  end

  test "last day of November" do
    user = create :user
    badge = create :december_diversions_badge
    track = create :track, slug: 'wren'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 11, 30)
    end
    assert badge.award_to?(user.reload)
  end

  test "any day of December" do
    user = create :user
    badge = create :december_diversions_badge
    track = create :track, slug: 'wren'

    [1, 7, 14, 25, 31].each do |day|
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 12, day)
    end

    assert badge.award_to?(user.reload)
  end

  test "first day of January" do
    user = create :user
    badge = create :december_diversions_badge
    track = create :track, slug: 'wren'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2024, 1, 1)
    end

    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    wren = create :track, slug: 'wren'
    csharp = create :track, slug: 'csharp'
    assert Badges::DecemberDiversionsBadge.worth_queuing?(exercise: create(:practice_exercise, track: wren))
    refute Badges::DecemberDiversionsBadge.worth_queuing?(exercise: create(:practice_exercise, track: wren, slug: 'hello-world'))
    refute Badges::DecemberDiversionsBadge.worth_queuing?(exercise: create(:practice_exercise, track: csharp))
  end
end
