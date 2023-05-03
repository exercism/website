require "test_helper"

class Badge::LifetimeInsiderBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :lifetime_insider_badge
    assert_equal "Lifetime Insider", badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :'lifetime-insiders', badge.icon
    assert_equal "One of the Lifetime Insiders", badge.description
    assert badge.send_email_on_acquisition?
  end

  test "award_to?" do
    badge = create :lifetime_insider_badge
    user = create :user

    %i[unset ineligible eligible eligible_lifetime active].each do |insiders_status|
      user.update(insiders_status:)
      refute badge.award_to?(user)
    end

    user.update(insiders_status: :active_lifetime)
    assert badge.award_to?(user)
  end
end
