require "test_helper"

class User::SetDiscordRolesTest < ActiveSupport::TestCase
  test "removes roles for normal discord user" do
    uid = '111'
    user = create :user, :not_mentor, discord_uid: uid

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
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1192435804602105966",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "noops for for non-discord user" do
    user = create :user, :not_mentor, :maintainer

    RestClient.expects(:put).never
    RestClient.expects(:delete).never

    User::SetDiscordRoles.(user)
  end

  test "adds maintainer role when user is maintainer" do
    uid = SecureRandom.hex
    user = create :user, :not_mentor, :maintainer, discord_uid: uid

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1192435804602105966",
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
    user = create :user, :not_mentor, discord_uid: uid

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
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1192435804602105966",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "adds mentor role when user is mentor" do
    uid = SecureRandom.hex
    user = create :user, discord_uid: uid
    create(:user_track_mentorship, user:)

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
    RestClient.expects(:put).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1192435804602105966",
      {},
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "removes mentor role when user is not a mentor" do
    uid = SecureRandom.hex
    user = create :user, :not_mentor, discord_uid: uid

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
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1192435804602105966",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )

    User::SetDiscordRoles.(user)
  end

  test "add supermentor role when user is supermentor" do
    uid = SecureRandom.hex
    user = create :user, :not_mentor, :supermentor, discord_uid: uid

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1192435804602105966",
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
    user = create :user, :not_mentor, discord_uid: uid

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1192435804602105966",
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
    user = create :user, :not_mentor, :insider, discord_uid: uid

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1192435804602105966",
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
    user = create :user, :not_mentor, discord_uid: uid

    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681",
      Authorization: "Bot #{Exercism.secrets.discord_bot_token}"
    )
    RestClient.expects(:delete).with(
      "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1192435804602105966",
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
    user = create :user, :not_mentor, :insider, discord_uid: uid

    RestClient.expects(:delete).raises(RestClient::NotFound).times(3)
    RestClient.expects(:put).raises(RestClient::NotFound)

    User::SetDiscordRoles.(user)
  end

  test "requeues when rate limit is reached" do
    uid = SecureRandom.hex
    user = create :user, :not_mentor, :maintainer, discord_uid: uid

    # The first three calls are fine, no rate limit issues
    stub_request(:delete, "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196488436633681").
      to_return(status: 200, body: "", headers: {})

    stub_request(:delete, "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1096024168639766578").
      to_return(status: 200, body: "", headers: {})

    stub_request(:delete, "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1192435804602105966").
      to_return(status: 200, body: "", headers: {})

    # The fourth call hits the rate limit
    stub_request(:put, "https://discord.com/api/guilds/854117591135027261/members/#{uid}/roles/1085196376058646559").
      to_return(
        status: 429,
        headers: { "Retry-After": 25 }
      )

    Mocha::Configuration.override(stubbing_non_existent_method: :allow) do
      cmd = User::SetDiscordRoles.new(user)
      cmd.expects(:requeue_job!).with(25)
      cmd.()
    end
  end
end
