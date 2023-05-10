require "test_helper"

class Badge::TroubleshooterBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :troubleshooter_badge
    assert_equal "Troubleshooter", badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :troubleshooter, badge.icon
    assert_equal 'Helped troubleshoot issues', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award to troubleshooter user" do
    badge = create :troubleshooter_badge

    %w[
      angelikatyborska
      iHiD
      kotp
      kytrinyx
      NobbZ
      SleeplessByte
    ].each do |github_username|
      troubleshooter_user = create(:user, github_username:)
      assert badge.award_to?(troubleshooter_user)
    end
  end

  test "award to troubleshooter user case-insensitive" do
    badge = create :troubleshooter_badge

    # Checks username case-insensitive
    %w[sleeplessbyte SLEEPLESSBYTE SleeplessByte].each do |github_username|
      user = create(:user, github_username:)
      assert badge.award_to?(user)
      user.destroy
    end
  end

  test "don't award to non-troubleshooter user" do
    badge = create :troubleshooter_badge

    non_pioneer_user = create :user
    refute badge.award_to?(non_pioneer_user)
  end

  test "don't award to non-github user" do
    badge = create :troubleshooter_badge

    non_github_user = create :user, github_username: nil
    refute badge.award_to?(non_github_user)
  end
end
