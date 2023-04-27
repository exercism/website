require "test_helper"

class Badges::AnalyticalAprilBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :analytical_april_badge
    assert_equal "Analytical April", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'badge-analytical-april', badge.icon
    assert_equal 'Completed and published five exercises in an analytical language in April', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :analytical_april_badge
    python = create :track, slug: 'python'
    csharp = create :track, slug: 'csharp'

    # No solutions
    refute badge.award_to?(user.reload)

    # hello world doesn't count
    exercise = create :practice_exercise, slug: 'hello-world', track: python
    create :practice_solution, :published, user:, track: python, exercise:, published_at: Time.utc(2023, 4, 1)
    refute badge.award_to?(user.reload)

    # 4 bob's is not enough
    4.times do |idx|
      exercise = create :practice_exercise, slug: 'bob', track: python
      create :practice_solution, :published, user:, track: python, exercise:, published_at: Time.utc(2023, 4, idx + 5)
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th exercise in csharp
    another_exercise = create :practice_exercise, slug: 'leap', track: csharp
    create :practice_solution, :published, user:, track: csharp, exercise: another_exercise, published_at: Time.utc(2023, 4, 6)
    refute badge.award_to?(user.reload)

    # Iterate a 5th bob, but in March
    exercise = create :practice_exercise, slug: 'bob', track: python
    solution = create :practice_solution, :published, user:, track: python, exercise:,
      published_at: Time.utc(2023, 3, 30)
    refute badge.award_to?(user.reload)

    # Complete it
    solution.update(completed_at: Time.utc(2023, 4, 27))
    refute badge.award_to?(user.reload)

    # Publish it
    solution.update(published_at: Time.utc(2023, 4, 28))
    assert badge.award_to?(user.reload)
  end

  test "last day of march" do
    user = create :user
    badge = create :analytical_april_badge
    python = create :track, slug: 'python'
    5.times do
      exercise = create :practice_exercise, slug: 'bob', track: python
      create :practice_solution, :published, user:, track: python, exercise:,
        published_at: Time.utc(2023, 3, 31)
    end
    assert badge.award_to?(user.reload)
  end

  test "last day of may" do
    user = create :user
    badge = create :analytical_april_badge
    python = create :track, slug: 'python'
    5.times do
      exercise = create :practice_exercise, slug: 'bob', track: python
      create :practice_solution, :published, user:, track: python, exercise:,
        published_at: Time.utc(2023, 5, 1)
    end
    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    python = create :track, slug: 'python'
    csharp = create :track, slug: 'csharp'
    assert Badges::AnalyticalAprilBadge.worth_queuing?(exercise: create(:practice_exercise, track: python))
    refute Badges::AnalyticalAprilBadge.worth_queuing?(exercise: create(:practice_exercise, track: python, slug: 'hello-world'))
    refute Badges::AnalyticalAprilBadge.worth_queuing?(exercise: create(:practice_exercise, track: csharp))
  end
end
