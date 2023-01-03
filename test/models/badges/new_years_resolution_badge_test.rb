require "test_helper"

class Badge::NewYearsResolutionBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :new_years_resolution_badge
    assert_equal "New Year's resolution", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'new-years-resolution', badge.icon
    assert_equal "Submitted an iteration on January 1st", badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :new_years_resolution_badge

    # No iterations
    refute badge.award_to?(user.reload)

    # Iteration created on last second of the 31st of December
    iteration = create :iteration, created_at: Time.utc(2018, 12, 31, 23, 59, 59), user: user
    refute badge.award_to?(user.reload)

    # Iteration created on first second of the 1st of January
    iteration.update(created_at: Time.utc(2019, 1, 1, 0, 0, 0))
    assert badge.award_to?(user.reload)

    # Iteration created on last second of the 1st of January
    iteration.update(created_at: Time.utc(2019, 1, 1, 23, 59, 59))
    assert badge.award_to?(user.reload)

    # Iteration created on first second of the 2st of January
    iteration.update(created_at: Time.utc(2019, 1, 2, 0, 0, 0))
    refute badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    (2..366).each do |day|
      iteration = create :iteration, created_at: Date.ordinal(2020, day)
      refute Badges::NewYearsResolutionBadge.worth_queuing?(iteration:)
    end

    iteration = create :iteration, created_at: Date.ordinal(2020, 1)
    assert Badges::NewYearsResolutionBadge.worth_queuing?(iteration:)
  end
end
