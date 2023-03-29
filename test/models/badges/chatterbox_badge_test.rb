require "test_helper"

class Badge::ChatterboxBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :chatterbox_badge
    assert_equal "Chatterbox", badge.name
    assert_equal :common, badge.rarity
    assert_equal :chatterbox, badge.icon
    assert_equal "Joined Exercism's Discord server", badge.description
    refute badge.send_email_on_acquisition?
  end

  test "award_to?" do
    user = create :user
    badge = create :chatterbox_badge

    # Not linked to Discord
    user.update(discord_uid: nil)
    refute badge.award_to?(user.reload)

    # Linked to Discord
    user.update(discord_uid: 772_134)
    assert badge.award_to?(user.reload)
  end
end
