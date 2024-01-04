class User::SetDiscordRoles
  include Mandate

  queue_as :default
  initialize_with :user

  def call
    return unless user.discord_uid.present?

    [
      [MAINTAINER_ROLE_ID, user.maintainer?],
      [SUPERMENTOR_ROLE_ID, user.supermentor?],
      [MENTOR_ROLE_ID, user.mentor?],
      [INSIDERS_ROLE_ID, user.insider?]
    ].each do |role_id, condition|
      add_or_remove!(role_id, condition)
    end
  end

  private
  def add_or_remove!(role_id, condition)
    if condition
      add_role!(role_id)
    else
      remove_role!(role_id)
    end
  end

  def add_role!(role_id)
    url = API_URL % [GUILD_ID, user.discord_uid, role_id]
    RestClient.put(url, {}, Authorization: AUTH_HEADER)
  rescue RestClient::NotFound
    # If the user could not be found, ignore the error
  rescue RestClient::TooManyRequests => e
    retry_after = (e.http_headers[:retry_after].presence || 60).to_i
    requeue_job!(retry_after.seconds)
  end

  def remove_role!(role_id)
    url = API_URL % [GUILD_ID, user.discord_uid, role_id]
    RestClient.delete(url, Authorization: AUTH_HEADER)
  rescue RestClient::NotFound
    # If the user could not be found, ignore the error
  rescue RestClient::TooManyRequests => e
    retry_after = (e.http_headers[:retry_after].presence || 60).to_i
    requeue_job!(retry_after.seconds)
  end

  API_URL =  "https://discord.com/api/guilds/%s/members/%s/roles/%s".freeze
  GUILD_ID = "854117591135027261".freeze
  MAINTAINER_ROLE_ID = "1085196376058646559".freeze
  SUPERMENTOR_ROLE_ID = "1085196488436633681".freeze
  MENTOR_ROLE_ID = "1192435804602105966".freeze
  INSIDERS_ROLE_ID = "1096024168639766578".freeze
  AUTH_HEADER = "Bot #{Exercism.secrets.discord_bot_token}".freeze
  private_constant :API_URL, :GUILD_ID, :MAINTAINER_ROLE_ID, :SUPERMENTOR_ROLE_ID, :AUTH_HEADER
end
