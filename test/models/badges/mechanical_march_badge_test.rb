require "test_helper"

class Badges::MechanicalMarchBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :mechanical_march_badge
    assert_equal "Mechanical March", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'badge-machine-code', badge.icon
    assert_equal 'Completed and published five exercises in a systems language in March', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :mechanical_march_badge
    rust = create :track, slug: 'rust'
    csharp = create :track, slug: 'csharp'

    # No solutions
    refute badge.award_to?(user.reload)

    # hello world doesn't count
    exercise = create :practice_exercise, slug: 'hello-world', track: rust
    create :practice_solution, :published, user:, track: rust, exercise:, published_at: Time.utc(2023, 3, 1)
    refute badge.award_to?(user.reload)

    # 4 bob's is not enough
    4.times do |idx|
      exercise = create :practice_exercise, slug: 'bob', track: rust
      create :practice_solution, :published, user:, track: rust, exercise:, published_at: Time.utc(2023, 3, idx + 5)
    end
    refute badge.award_to?(user.reload)

    # Doesn't care if we get a 5th exercise in csharp
    another_exercise = create :practice_exercise, slug: 'leap', track: csharp
    create :practice_solution, :published, user:, track: csharp, exercise: another_exercise, published_at: Time.utc(2023, 3, 6)
    refute badge.award_to?(user.reload)

    # Iterate a 5th bob, but in February
    exercise = create :practice_exercise, slug: 'bob', track: rust
    solution = create :practice_solution, :published, user:, track: rust, exercise:,
      published_at: Time.utc(2023, 2, 1)
    refute badge.award_to?(user.reload)

    # Complete it
    solution.update(completed_at: Time.utc(2023, 3, 27))
    refute badge.award_to?(user.reload)

    # Publish it
    solution.update(published_at: Time.utc(2023, 3, 28))
    assert badge.award_to?(user.reload)
  end

  test "28th of feb" do
    user = create :user
    badge = create :mechanical_march_badge
    rust = create :track, slug: 'rust'
    5.times do
      exercise = create :practice_exercise, slug: 'bob', track: rust
      create :practice_solution, :published, user:, track: rust, exercise:,
        published_at: Time.utc(2023, 2, 28)
    end
    assert badge.award_to?(user.reload)
  end

  test "29th of feb" do
    user = create :user
    badge = create :mechanical_march_badge
    rust = create :track, slug: 'rust'
    5.times do
      exercise = create :practice_exercise, slug: 'bob', track: rust
      create :practice_solution, :published, user:, track: rust, exercise:,
        published_at: Time.utc(2024, 2, 29)
    end
    assert badge.award_to?(user.reload)
  end

  test "first day of april" do
    user = create :user
    badge = create :mechanical_march_badge
    rust = create :track, slug: 'rust'
    5.times do
      exercise = create :practice_exercise, slug: 'bob', track: rust
      create :practice_solution, :published, user:, track: rust, exercise:,
        published_at: Time.utc(2023, 4, 1)
    end
    assert badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    rust = create :track, slug: 'rust'
    csharp = create :track, slug: 'csharp'
    assert Badges::MechanicalMarchBadge.worth_queuing?(exercise: create(:practice_exercise, track: rust))
    refute Badges::MechanicalMarchBadge.worth_queuing?(exercise: create(:practice_exercise, track: rust, slug: 'hello-world'))
    refute Badges::MechanicalMarchBadge.worth_queuing?(exercise: create(:practice_exercise, track: csharp))
  end
end
