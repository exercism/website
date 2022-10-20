class User::SetDiscourseTrustLevel
  include Mandate

  initialize_with :user

  def call
    return unless user.reputation >= 20

    discourse_user_id = client.by_external_id(user.id)['id']
    client.update_trust_level(discourse_user_id, level: 2)
  end

  def client
    DiscourseApi::Client.new("https://forum.exercism.org").tap do |client|
      client.api_key = Exercism.secrets.discourse_api_key
      client.api_username = "system"
    end
  end
end
