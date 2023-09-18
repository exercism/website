require "test_helper"

class Badges::SummerOfSexpsBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :summer_of_sexps_badge
    assert_equal "Summer of Sexps", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'badge-summer-of-sexps', badge.icon
    assert_equal 'Completed and published five exercises in a Lisp dialect in June', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :summer_of_sexps_badge
    clojure = create :track, slug: 'clojure'
    csharp = create :track, slug: 'csharp'

    # No solutions
    refute badge.award_to?(user.reload)

    # hello world doesn't count
    exercise = create :practice_exercise, slug: 'hello-world', track: clojure
    create :practice_solution, :published, user:, track: clojure, exercise:, published_at: Time.utc(2023, 6, 1)
    refute badge.award_to?(user.reload)

    # 4 bob's is not enough
    4.times do |idx|
      exercise = create :practice_exercise, slug: 'bob', track: clojure
      create :practice_solution, :published, user:, track: clojure, exercise:, published_at: Time.utc(2023, 6, idx + 5)
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th exercise in csharp
    another_exercise = create :practice_exercise, slug: 'leap', track: csharp
    create :practice_solution, :published, user:, track: csharp, exercise: another_exercise, published_at: Time.utc(2023, 6, 6)
    refute badge.award_to?(user.reload)

    # Iterate a 5th bob, but in May
    exercise = create :practice_exercise, slug: 'bob', track: clojure
    solution = create :practice_solution, :published, user:, track: clojure, exercise:,
      published_at: Time.utc(2023, 5, 20)
    refute badge.award_to?(user.reload)

    # Complete it
    solution.update(completed_at: Time.utc(2023, 6, 27))
    refute badge.award_to?(user.reload)

    # Publish it
    solution.update(published_at: Time.utc(2023, 6, 28))
    assert badge.award_to?(user.reload)
  end

  test "last day of May" do
    user = create :user
    badge = create :summer_of_sexps_badge
    track = create :track, slug: 'clojure'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 5, 31)
    end
    assert badge.award_to?(user.reload)
  end

  test "any day of June" do
    user = create :user
    badge = create :summer_of_sexps_badge
    track = create :track, slug: 'clojure'

    [1, 7, 14, 25, 30].each do |day|
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 6, day)
    end

    assert badge.award_to?(user.reload)
  end

  test "first day of July" do
    user = create :user
    badge = create :summer_of_sexps_badge
    track = create :track, slug: 'clojure'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 7, 1)
    end

    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    clojure = create :track, slug: 'clojure'
    csharp = create :track, slug: 'csharp'
    assert Badges::SummerOfSexpsBadge.worth_queuing?(exercise: create(:practice_exercise, track: clojure))
    refute Badges::SummerOfSexpsBadge.worth_queuing?(exercise: create(:practice_exercise, track: clojure, slug: 'hello-world'))
    refute Badges::SummerOfSexpsBadge.worth_queuing?(exercise: create(:practice_exercise, track: csharp))
  end
end
