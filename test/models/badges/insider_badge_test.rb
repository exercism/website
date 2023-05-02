require "test_helper"

class Badge::InsiderBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :insider_badge
    assert_equal "Insider", badge.name
    assert_equal :ultimate, badge.rarity
    assert_equal :insiders, badge.icon
    assert_equal "Member of Exercism Insiders", badge.description
    assert badge.send_email_on_acquisition?
  end

  test "award_to?" do
    badge = create :insider_badge
    user = create :user

    %i[unset ineligible eligible eligible_lifetime].each do |insiders_status|
      user.update(insiders_status:)
      refute badge.award_to?(user)
    end

    %i[active active_lifetime].each do |insiders_status|
      user.update(insiders_status:)
      assert badge.award_to?(user)
    end
  end
end
