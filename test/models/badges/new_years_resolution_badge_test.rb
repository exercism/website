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

    iteration = create(:iteration, user:)

    # Iteration created on 30st of December
    iteration.update(created_at: Time.utc(2019, 12, 30, 23, 59, 59))
    refute badge.award_to?(user.reload)

    # Iteration created on 31st of December
    iteration.update(created_at: Time.utc(2019, 12, 31, 0, 0, 0))
    assert badge.award_to?(user.reload)

    # Iteration created on 31st of December (leap year)
    iteration.update(created_at: Time.utc(2020, 12, 31, 0, 0, 0))
    assert badge.award_to?(user.reload)

    # Iteration created on 1st of January
    iteration.update(created_at: Time.utc(2019, 1, 1, 0, 0, 0))
    assert badge.award_to?(user.reload)

    # Iteration created on 2nd of January
    iteration.update(created_at: Time.utc(2019, 1, 2, 0, 0, 0))
    assert badge.award_to?(user.reload)

    # Iteration created on 3rd of January
    iteration.update(created_at: Time.utc(2019, 1, 3, 0, 0, 0))
    refute badge.award_to?(user.reload)
  end

  test "worth_queuing?" do
    iteration = create :iteration, created_at: Date.ordinal(2020, 1)
    assert Badges::NewYearsResolutionBadge.worth_queuing?(iteration:)

    iteration = create :iteration, created_at: Date.ordinal(2020, 2)
    assert Badges::NewYearsResolutionBadge.worth_queuing?(iteration:)

    iteration = create :iteration, created_at: Date.ordinal(2019, 365)
    assert Badges::NewYearsResolutionBadge.worth_queuing?(iteration:)

    iteration = create :iteration, created_at: Date.ordinal(2020, 366)
    assert Badges::NewYearsResolutionBadge.worth_queuing?(iteration:)

    (3..364).each do |day|
      iteration = create :iteration, created_at: Date.ordinal(2020, day)
      refute Badges::NewYearsResolutionBadge.worth_queuing?(iteration:)
    end
  end
end
