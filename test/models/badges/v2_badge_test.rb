require "test_helper"

class Badge::V2BadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :v2_badge
    assert_equal "v2", badge.name
    assert_equal :common, badge.rarity
    assert_equal :v2, badge.icon
    assert_equal 'Joined Exercism before September 1st 2021', badge.description
    refute badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    v2_release_date = Time.new(2018, 7, 13, 10, 1, 29, 0)
    v3_release_date = Time.new(2021, 9, 1, 0, 0, 0, 0)
    user = create :user
    badge = create :v2_badge

    # Award if created before v2 release date and confirmed
    user.update!(created_at: v2_release_date - 1.day, confirmed_at: Time.current)
    assert badge.award_to?(user.reload)

    # Don't award if created before v2 release date but not confirmed
    user.update!(created_at: v2_release_date - 1.day, confirmed_at: nil)
    refute badge.award_to?(user.reload)

    # Award if created before v3 release date and confirmed
    user.update!(created_at: v3_release_date - 1.day, confirmed_at: Time.current)
    assert badge.award_to?(user.reload)

    # Don't award if created before v3 release date but not confirmed
    user.update!(created_at: v3_release_date - 1.day, confirmed_at: nil)
    refute badge.award_to?(user.reload)

    # Don't award if created at v3 release date
    user.update!(created_at: v3_release_date, confirmed_at: Time.current)
    refute badge.award_to?(user.reload)

    # Don't award if created after v3 release date
    user.update!(created_at: v3_release_date + 1.day, confirmed_at: Time.current)
    refute badge.award_to?(user.reload)

    # Don't award if created now
    user.update!(created_at: Time.current, confirmed_at: Time.current)
    refute badge.award_to?(user.reload)
  end
end
