require "test_helper"

class Badges::FunctionalFebruaryBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :functional_february_badge
    assert_equal "Functional February", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :functional, badge.icon
    assert_equal 'Completed and published five exercises in a functional language in February', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :functional_february_badge
    fsharp = create :track, slug: 'fsharp'
    csharp = create :track, slug: 'csharp'

    # No solutions
    refute badge.award_to?(user.reload)

    # hello world doesn't count
    exercise = create :practice_exercise, slug: 'hello-world', track: fsharp
    create :practice_solution, :published, user:, track: fsharp, exercise:, published_at: Time.utc(2022, 2, 1)
    refute badge.award_to?(user.reload)

    # 4 bob's is not enough
    4.times do |idx|
      exercise = create :practice_exercise, slug: 'bob', track: fsharp
      create :practice_solution, :published, user:, track: fsharp, exercise:, published_at: Time.utc(2022, 2, idx + 5)
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th exercise in csharp
    another_exercise = create :practice_exercise, slug: 'leap', track: csharp
    create :practice_solution, :published, user:, track: csharp, exercise: another_exercise, published_at: Time.utc(2022, 2, 28)
    refute badge.award_to?(user.reload)

    # Publish a 5th bob, but on second of march
    exercise = create :practice_exercise, slug: 'bob', track: fsharp
    solution = create :practice_solution, :iterated, user:, track: fsharp, exercise:,
      published_at: Time.utc(2022, 3, 2)
    refute badge.award_to?(user.reload)

    # Complete it
    solution.update(completed_at: Time.utc(2022, 2, 27))
    refute badge.award_to?(user.reload)

    # Publish it
    solution.update(published_at: Time.utc(2022, 2, 28))
    assert badge.award_to?(user.reload)
  end

  test "31st of jan" do
    user = create :user
    badge = create :functional_february_badge
    fsharp = create :track, slug: 'fsharp'
    5.times do
      exercise = create :practice_exercise, slug: 'bob', track: fsharp
      create :practice_solution, :iterated, user:, track: fsharp, exercise:,
        published_at: Time.utc(2023, 1, 31)
    end
    assert badge.award_to?(user.reload)
  end

  test "first day of march" do
    user = create :user
    badge = create :functional_february_badge
    fsharp = create :track, slug: 'fsharp'
    5.times do
      exercise = create :practice_exercise, slug: 'bob', track: fsharp
      create :practice_solution, :iterated, user:, track: fsharp, exercise:,
        published_at: Time.utc(2023, 3, 1)
    end
    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    fsharp = create :track, slug: 'fsharp'
    csharp = create :track, slug: 'csharp'
    assert Badges::FunctionalFebruaryBadge.worth_queuing?(exercise: create(:practice_exercise, track: fsharp))
    refute Badges::FunctionalFebruaryBadge.worth_queuing?(exercise: create(:practice_exercise, track: fsharp, slug: 'hello-world'))
    refute Badges::FunctionalFebruaryBadge.worth_queuing?(exercise: create(:practice_exercise, track: csharp))
  end
end
