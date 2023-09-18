require "test_helper"

class User::LinkWithDiscordTest < ActiveSupport::TestCase
  test "noops with same user" do
    uid = '111'
    auth = stub(uid:)
    user = create :user, discord_uid: uid

    User::SetDiscordRoles.expects(:defer).with(user)

    User::LinkWithDiscord.(user, auth)

    assert_equal uid, user.reload.discord_uid
  end

  test "updates user" do
    uid = '111'
    auth = stub(uid:)
    user = create :user

    User::SetDiscordRoles.expects(:defer).with(user)

    User::LinkWithDiscord.(user, auth)

    assert_equal uid, user.discord_uid
  end

  test "unsets old user user" do
    uid = '111'
    auth = stub(uid:)
    old_user = create :user, discord_uid: uid
    new_user = create :user

    User::SetDiscordRoles.expects(:defer).with(new_user)

    User::LinkWithDiscord.(new_user, auth)

    assert_nil old_user.reload.discord_uid
    assert_equal uid, new_user.reload.discord_uid
  end

  test "awards chatterbox badge" do
    uid = '111'
    auth = stub(uid:)
    user = create :user, discord_uid: nil

    User::SetDiscordRoles.expects(:defer).with(user)

    perform_enqueued_jobs do
      User::LinkWithDiscord.(user, auth)
    end

    assert_includes user.reload.badges.map(&:class), Badges::ChatterboxBadge
  end
end
