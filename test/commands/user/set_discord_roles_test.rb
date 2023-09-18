require "test_helper"

class User::SetDiscordRolesTest < ActiveSupport::TestCase
  test "removes roles for normal discord user" do
    uid = '111'
    user = create :user, discord_uid: uid

    RestClient.expects(:put).never
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "noops for for non-discord user" do
    user = create :user, :maintainer

    RestClient.expects(:put).never
    RestClient.expects(:delete).never

    User::SetDiscordRoles.(user)
  end

  test "adds maintainer role when user is maintainer" do
    uid = SecureRandom.hex
    user = create :user, :maintainer, discord_uid: uid

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:put).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      {},
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "removes maintainer role when user is not a maintainer" do
    uid = SecureRandom.hex
    user = create :user, discord_uid: uid

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "add supermentor role when user is supermentor" do
    uid = SecureRandom.hex
    user = create :user, :supermentor, discord_uid: uid

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    RestClient.expects(:put).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681",
      {},
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "removes supermentor role when user is not a supermentor" do
    uid = SecureRandom.hex
    user = create :user, discord_uid: uid

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "adds insiders role when user is insider" do
    uid = SecureRandom.hex
    user = create :user, :insider, discord_uid: uid

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:put).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578",
      {},
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "removes insiders role when user is not an insider" do
    uid = SecureRandom.hex
    user = create :user, discord_uid: uid

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "gracefully handles 404 insiders role when user is not an insider" do
    uid = SecureRandom.hex
    user = create :user, :insider, discord_uid: uid

    RestClient.expects(:delete).raises(RestClient::NotFound).twice
    RestClient.expects(:put).raises(RestClient::NotFound)

    User::SetDiscordRoles.(user)
  end
end
