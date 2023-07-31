require "test_helper"

class Badges::AppsAugustBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :apps_august_badge
    assert_equal "Appy August", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'badge-apps-august', badge.icon
    assert_equal 'Completed and published five exercises in an App-building language in August', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :apps_august_badge
    kotlin = create :track, slug: 'kotlin'
    csharp = create :track, slug: 'csharp'

    # No solutions
    refute badge.award_to?(user.reload)

    # hello world doesn't count
    exercise = create :practice_exercise, slug: 'hello-world', track: kotlin
    create :practice_solution, :published, user:, track: kotlin, exercise:, published_at: Time.utc(2023, 8, 1)
    refute badge.award_to?(user.reload)

    # 4 bob's is not enough
    4.times do |idx|
      exercise = create :practice_exercise, slug: 'bob', track: kotlin
      create :practice_solution, :published, user:, track: kotlin, exercise:, published_at: Time.utc(2023, 8, idx + 5)
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th exercise in csharp
    another_exercise = create :practice_exercise, slug: 'leap', track: csharp
    create :practice_solution, :published, user:, track: csharp, exercise: another_exercise, published_at: Time.utc(2023, 8, 6)
    refute badge.award_to?(user.reload)

    # Iterate a 5th bob, but in July
    exercise = create :practice_exercise, slug: 'bob', track: kotlin
    solution = create :practice_solution, :published, user:, track: kotlin, exercise:,
      published_at: Time.utc(2023, 7, 20)
    refute badge.award_to?(user.reload)

    # Complete it
    solution.update(completed_at: Time.utc(2023, 8, 27))
    refute badge.award_to?(user.reload)

    # Publish it
    solution.update(published_at: Time.utc(2023, 8, 28))
    assert badge.award_to?(user.reload)
  end

  test "last day of July" do
    user = create :user
    badge = create :apps_august_badge
    track = create :track, slug: 'kotlin'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 7, 31)
    end
    assert badge.award_to?(user.reload)
  end

  test "any day of August" do
    user = create :user
    badge = create :apps_august_badge
    track = create :track, slug: 'kotlin'

    [1, 7, 14, 25, 31].each do |day|
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 8, day)
    end

    assert badge.award_to?(user.reload)
  end

  test "first day of September" do
    user = create :user
    badge = create :apps_august_badge
    track = create :track, slug: 'kotlin'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 9, 1)
    end

    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    kotlin = create :track, slug: 'kotlin'
    csharp = create :track, slug: 'csharp'
    assert Badges::AppsAugustBadge.worth_queuing?(exercise: create(:practice_exercise, track: kotlin))
    refute Badges::AppsAugustBadge.worth_queuing?(exercise: create(:practice_exercise, track: kotlin, slug: 'hello-world'))
    refute Badges::AppsAugustBadge.worth_queuing?(exercise: create(:practice_exercise, track: csharp))
  end
end
