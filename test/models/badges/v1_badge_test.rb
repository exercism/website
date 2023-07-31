require "test_helper"

class Badge::V1BadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :v1_badge
    assert_equal "v1", badge.name
    assert_equal :common, badge.rarity
    assert_equal :v1, badge.icon # rubocop:disable Naming/VariableNumber
    assert_equal 'Joined Exercism before July 13th 2018', badge.description
    refute badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    v2_release_date = Time.new(2018, 7, 13, 10, 1, 29, 0)
    user = create :user
    badge = create :v1_badge

    # Award if created before v2 release date and confirmed
    user.update!(created_at: v2_release_date - 1.day, confirmed_at: Time.current)
    assert badge.award_to?(user.reload)

    # Don't award if created before v2 release date but not confirmed
    user.update!(created_at: v2_release_date - 1.day, confirmed_at: nil)
    refute badge.award_to?(user.reload)

    # Don't award if created at v2 release date
    user.update!(created_at: v2_release_date, confirmed_at: Time.current)
    refute badge.award_to?(user.reload)

    # Don't award if created after v2 release date
    user.update!(created_at: v2_release_date + 1.day, confirmed_at: Time.current)
    refute badge.award_to?(user.reload)

    # Don't award if created now
    user.update!(created_at: Time.current, confirmed_at: Time.current)
    refute badge.award_to?(user.reload)
  end
end
