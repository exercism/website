require "test_helper"

class Badges::DiscourserBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :discourser_badge
    assert_equal "Discourser", badge.name
    assert_equal :common, badge.rarity
    assert_equal :discourser, badge.icon
    assert_equal "Joined Exercism's forum", badge.description
    refute badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    user = create :user
    badge = create :discourser_badge

    # Not registered with Discourse
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_raise(DiscourseApi::NotFoundError)
    refute badge.award_to?(user.reload)

    # Registered with Discourse
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: { user: { id: 123 } }.to_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    assert badge.award_to?(user.reload)
  end
end
