require "test_helper"

class Badge::BardBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :bard_badge
    assert_equal "Bard", badge.name
    assert_equal :ultimate, badge.rarity
    assert_equal :bard, badge.icon
    assert_equal 'Created an exercise story', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award to bard user" do
    badge = create :bard_badge

    %w[
      TODO
    ].each do |github_username|
      bard_user = create :user, github_username: github_username
      assert badge.award_to?(bard_user)
    end
  end

  test "award to bard user case-insensitive" do
    badge = create :bard_badge

    # Checks username case-insensitive
    %w[todo TODO toDo].each do |github_username|
      user = create :user, github_username: github_username
      assert badge.award_to?(user)
      user.destroy
    end
  end

  test "don't award to non-bard user" do
    badge = create :bard_badge

    non_pioneer_user = create :user
    refute badge.award_to?(non_pioneer_user)
  end

  test "don't award to non-github user" do
    badge = create :bard_badge

    non_github_user = create :user, github_username: nil
    refute badge.award_to?(non_github_user)
  end
end
