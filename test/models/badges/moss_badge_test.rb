require "test_helper"

class Badge::MossBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :moss_badge
    assert_equal 'Moss', badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :moss, badge.icon
    assert_equal 'Provided support to new users', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award to supporter user" do
    badge = create :moss_badge

    %w[
      andrerfcsantos
      BethanyG
      erikschierboom
      glennj
      ihid
      kotp
      NobbZ
      SleeplessByte
      ynfle
    ].each do |github_username|
      supporter_user = create(:user, github_username:)
      assert badge.award_to?(supporter_user)
    end
  end

  test "award to supporter user case-insensitive" do
    badge = create :moss_badge

    # Checks username case-insensitive
    %w[erikschierboom ERIKSCHIERBOOM ErikSchierboom].each do |github_username|
      user = create(:user, github_username:)
      assert badge.award_to?(user)
      user.destroy
    end
  end

  test "don't award to non-supporter user" do
    badge = create :moss_badge

    non_supporter_user = create :user
    refute badge.award_to?(non_supporter_user)
  end

  test "don't award to non-github user" do
    badge = create :moss_badge

    non_github_user = create :user, github_username: nil
    refute badge.award_to?(non_github_user)
  end
end
