require "test_helper"

class Badges::NibblyNovemberBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :nibbly_november_badge
    assert_equal "Nibbly November", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'badge-nibbly-november', badge.icon
    assert_equal 'Completed and published five exercises in an assembly language in November', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :nibbly_november_badge
    wasm = create :track, slug: 'wasm'
    csharp = create :track, slug: 'csharp'

    # No solutions
    refute badge.award_to?(user.reload)

    # hello world doesn't count
    exercise = create :practice_exercise, slug: 'hello-world', track: wasm
    create :practice_solution, :published, user:, track: wasm, exercise:, published_at: Time.utc(2023, 11, 1)
    refute badge.award_to?(user.reload)

    # 4 bob's is not enough
    4.times do |idx|
      exercise = create :practice_exercise, slug: 'bob', track: wasm
      create :practice_solution, :published, user:, track: wasm, exercise:, published_at: Time.utc(2023, 11, idx + 5)
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th exercise in csharp
    another_exercise = create :practice_exercise, slug: 'leap', track: csharp
    create :practice_solution, :published, user:, track: csharp, exercise: another_exercise, published_at: Time.utc(2023, 11, 6)
    refute badge.award_to?(user.reload)

    # Iterate a 5th bob, but in October
    exercise = create :practice_exercise, slug: 'bob', track: wasm
    solution = create :practice_solution, :published, user:, track: wasm, exercise:,
      published_at: Time.utc(2023, 10, 20)
    refute badge.award_to?(user.reload)

    # Complete it
    solution.update(completed_at: Time.utc(2023, 11, 27))
    refute badge.award_to?(user.reload)

    # Publish it
    solution.update(published_at: Time.utc(2023, 11, 28))
    assert badge.award_to?(user.reload)
  end

  test "last day of October" do
    user = create :user
    badge = create :nibbly_november_badge
    track = create :track, slug: 'wasm'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 10, 31)
    end
    assert badge.award_to?(user.reload)
  end

  test "any day of November" do
    user = create :user
    badge = create :nibbly_november_badge
    track = create :track, slug: 'wasm'

    [1, 7, 14, 25, 30].each do |day|
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 11, day)
    end

    assert badge.award_to?(user.reload)
  end

  test "first day of December" do
    user = create :user
    badge = create :nibbly_november_badge
    track = create :track, slug: 'wasm'

    5.times do
      exercise = create(:practice_exercise, track:)
      create :practice_solution, :published, user:, track:, exercise:, published_at: Time.utc(2023, 12, 1)
    end

    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    wasm = create :track, slug: 'wasm'
    csharp = create :track, slug: 'csharp'
    assert Badges::NibblyNovemberBadge.worth_queuing?(exercise: create(:practice_exercise, track: wasm))
    refute Badges::NibblyNovemberBadge.worth_queuing?(exercise: create(:practice_exercise, track: wasm, slug: 'hello-world'))
    refute Badges::NibblyNovemberBadge.worth_queuing?(exercise: create(:practice_exercise, track: csharp))
  end
end
