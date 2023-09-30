require "test_helper"

class Badges::ObjectOrientedOctoberBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :object_oriented_october_badge
    assert_equal "Object-Oriented October", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'badge-object-oriented-october', badge.icon
    assert_equal 'Completed and published five exercises in an object-oriented language in October', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :object_oriented_october_badge
    csharp = create :track, slug: 'csharp'
    jq = create :track, slug: 'jq'

    # No solutions
    refute badge.award_to?(user.reload)

    # hello world doesn't count
    exercise = create :practice_exercise, slug: 'hello-world', track: csharp
    create :practice_solution, :published, user:, track: csharp, exercise:, published_at: Time.utc(2023, 10, 1)
    refute badge.award_to?(user.reload)

    # 4 bob's is not enough
    4.times do |idx|
      exercise = create :practice_exercise, slug: 'bob', track: csharp
      create :practice_solution, :published, user:, track: csharp, exercise:, published_at: Time.utc(2023, 10, idx + 5)
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th exercise in csharp
    another_exercise = create :practice_exercise, slug: 'leap', track: jq
    create :practice_solution, :published, user:, track: jq, exercise: another_exercise, published_at: Time.utc(2023, 10, 6)
    refute badge.award_to?(user.reload)

    # Iterate a 5th bob, but in September
    exercise = create :practice_exercise, slug: 'bob', track: csharp
    solution = create :practice_solution, :published, user:, track: csharp, exercise:,
      published_at: Time.utc(2023, 9, 20)
    refute badge.award_to?(user.reload)

    # Complete it
    solution.update(completed_at: Time.utc(2023, 10, 27))
    refute badge.award_to?(user.reload)

    # Publish it
    solution.update(published_at: Time.utc(2023, 10, 28))
    assert badge.award_to?(user.reload)
  end

  test "last day of September" do
    user = create :user
    badge = create :object_oriented_october_badge
    track = create :track, slug: 'csharp'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 9, 30)
    end
    assert badge.award_to?(user.reload)
  end

  test "any day of October" do
    user = create :user
    badge = create :object_oriented_october_badge
    track = create :track, slug: 'csharp'

    [1, 7, 14, 25, 31].each do |day|
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 10, day)
    end

    assert badge.award_to?(user.reload)
  end

  test "first day of November" do
    user = create :user
    badge = create :object_oriented_october_badge
    track = create :track, slug: 'csharp'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 11, 1)
    end

    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    csharp = create :track, slug: 'csharp'
    jq = create :track, slug: 'jq'
    assert Badges::ObjectOrientedOctoberBadge.worth_queuing?(exercise: create(:practice_exercise, track: csharp))
    refute Badges::ObjectOrientedOctoberBadge.worth_queuing?(exercise: create(:practice_exercise, track: csharp, slug: 'hello-world'))
    refute Badges::ObjectOrientedOctoberBadge.worth_queuing?(exercise: create(:practice_exercise, track: jq))
  end
end
