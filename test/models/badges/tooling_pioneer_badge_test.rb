require "test_helper"

class Badge::ToolingPioneerBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :tooling_pioneer_badge
    assert_equal "Tooling Pioneer", badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :'tooling-pioneer', badge.icon
    assert_equal 'Developed early prototypes of tooling for Exercism', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award to tooling pioneer user" do
    badge = create :tooling_pioneer_badge

    %w[
      alirezaghey
      bergjohan
      ceddlyburge
      cmccandless
      coriolinus
      erikschierboom
      ihid
      mpizenberg
      seventhnadir
      sleeplessbyte
      tehsphinx
      thelostlambda
      yawpitch
    ].each do |github_username|
      tooling_pioneer_user = create(:user, github_username:)
      assert badge.award_to?(tooling_pioneer_user)
    end
  end

  test "award to tooling pioneer user case-insensitive" do
    badge = create :tooling_pioneer_badge

    # Checks username case-insensitive
    %w[erikschierboom ERIKSCHIERBOOM ErikSchierboom].each do |github_username|
      user = create(:user, github_username:)
      assert badge.award_to?(user)
      user.destroy
    end
  end

  test "don't award to non-tooling pioneer user" do
    badge = create :tooling_pioneer_badge

    non_tooling_pioneer_user = create :user
    refute badge.award_to?(non_tooling_pioneer_user)
  end

  test "don't award to non-github user" do
    badge = create :tooling_pioneer_badge

    non_github_user = create :user, github_username: nil
    refute badge.award_to?(non_github_user)
  end
end
