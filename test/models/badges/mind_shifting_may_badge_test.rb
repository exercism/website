require "test_helper"

class Badges::MindShiftingMayBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :mind_shifting_may_badge
    assert_equal "Mindshifting May", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'badge-mind-shifting-may', badge.icon
    assert_equal 'Completed and published five exercises in a mindshifting language in May', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :mind_shifting_may_badge
    prolog = create :track, slug: 'prolog'
    csharp = create :track, slug: 'csharp'

    # No solutions
    refute badge.award_to?(user.reload)

    # hello world doesn't count
    exercise = create :practice_exercise, slug: 'hello-world', track: prolog
    create :practice_solution, :published, user:, track: prolog, exercise:, published_at: Time.utc(2023, 5, 1)
    refute badge.award_to?(user.reload)

    # 4 bob's is not enough
    4.times do |idx|
      exercise = create :practice_exercise, slug: 'bob', track: prolog
      create :practice_solution, :published, user:, track: prolog, exercise:, published_at: Time.utc(2023, 5, idx + 5)
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th exercise in csharp
    another_exercise = create :practice_exercise, slug: 'leap', track: csharp
    create :practice_solution, :published, user:, track: csharp, exercise: another_exercise, published_at: Time.utc(2023, 5, 6)
    refute badge.award_to?(user.reload)

    # Iterate a 5th bob, but in April
    exercise = create :practice_exercise, slug: 'bob', track: prolog
    solution = create :practice_solution, :published, user:, track: prolog, exercise:,
      published_at: Time.utc(2023, 4, 20)
    refute badge.award_to?(user.reload)

    # Complete it
    solution.update(completed_at: Time.utc(2023, 5, 27))
    refute badge.award_to?(user.reload)

    # Publish it
    solution.update(published_at: Time.utc(2023, 5, 28))
    assert badge.award_to?(user.reload)
  end

  test "last day of April" do
    user = create :user
    badge = create :mind_shifting_may_badge
    track = create :track, slug: 'prolog'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 4, 30)
    end
    assert badge.award_to?(user.reload)
  end

  test "any day of May" do
    user = create :user
    badge = create :mind_shifting_may_badge
    track = create :track, slug: 'prolog'

    [1, 7, 14, 25, 31].each do |day|
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 5, day)
    end

    assert badge.award_to?(user.reload)
  end

  test "first day of June" do
    user = create :user
    badge = create :mind_shifting_may_badge
    track = create :track, slug: 'prolog'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 6, 1)
    end

    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    prolog = create :track, slug: 'prolog'
    csharp = create :track, slug: 'csharp'
    assert Badges::MindShiftingMayBadge.worth_queuing?(exercise: create(:practice_exercise, track: prolog))
    refute Badges::MindShiftingMayBadge.worth_queuing?(exercise: create(:practice_exercise, track: prolog, slug: 'hello-world'))
    refute Badges::MindShiftingMayBadge.worth_queuing?(exercise: create(:practice_exercise, track: csharp))
  end
end
