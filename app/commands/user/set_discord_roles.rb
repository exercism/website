class User::SetDiscordRoles
  include Mandate

  queue_as :default
  initialize_with :user

  def call
    return unless user.discord_uid.present?

    set_maintainer_role!
    set_supermentor_role!
    set_insiders_role!
  end

  def set_maintainer_role!
    return unless user.maintainer?

    set_role!(MAINTAINER_ROLE_ID)
  end

  def set_supermentor_role!
    return unless user.supermentor?

    set_role!(SUPERMENTOR_ROLE_ID)
  end

  def set_insiders_role!
    return unless user.insider?

    set_role!(INSIDERS_ROLE_ID)
  end

  def set_role!(role_id) # rubocop:disable Naming/AccessorMethodName
    url = API_URL % [GUILD_ID, user.discord_uid, role_id]
    RestClient.put(url, {}, Authorization: AUTH_HEADER)
  end

  API_URL =  "https://discord.com/api/guilds/%s/members/%s/roles/%s".freeze
  GUILD_ID = "854117591135027261".freeze
  MAINTAINER_ROLE_ID = "1085196376058646559".freeze
  SUPERMENTOR_ROLE_ID = "1085196488436633681".freeze
  INSIDERS_ROLE_ID = "1096024168639766578".freeze
  AUTH_HEADER = "Bot #{Exercism.secrets.discord_bot_token}".freeze
  private_constant :API_URL, :GUILD_ID, :MAINTAINER_ROLE_ID, :SUPERMENTOR_ROLE_ID, :AUTH_HEADER
end
