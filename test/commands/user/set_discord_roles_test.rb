require "test_helper"

class User::SetDiscordRolesTest < ActiveSupport::TestCase
  test "noops with normal user" do
    uid = '111'
    user = create :user, discord_uid: uid

    RestClient.expects(:put).never

    User::SetDiscordRoles.(user)
  end

  test "noops for non-discord user" do
    user = create :user, :maintainer

    RestClient.expects(:put).never

    User::SetDiscordRoles.(user)
  end

  test "writes maintainer role" do
    uid = SecureRandom.hex
    user = create :user, :maintainer, discord_uid: uid

    RestClient.expects(:put).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      {},
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "writes supermentor role" do
    uid = SecureRandom.hex
    user = create :user, :supermentor, discord_uid: uid

    RestClient.expects(:put).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681",
      {},
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "writes insiders role" do
    uid = SecureRandom.hex
    user = create :user, :insider, discord_uid: uid

    RestClient.expects(:put).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578",
      {},
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end
end
