require "openssl"
require "jwt"
require "rest-client"

module User::GithubSolutionSyncer::GithubApp
  class InstallationNotFoundError < StandardError; end

  def self.generate_jwt
    app_id = Exercism.secrets.github_solution_syncer_app_id
    private_key = OpenSSL::PKey::RSA.new(Exercism.secrets.github_solution_syncer_private_key.gsub("\\n", "\n"))

    payload = {
      iat: Time.now.to_i,
      exp: Time.now.to_i + 600,
      iss: app_id
    }

    JWT.encode(payload, private_key, "RS256")
  end

  def self.generate_installation_token!(installation_id)
    jwt = generate_jwt

    response = RestClient.post(
      "https://api.github.com/app/installations/#{installation_id}/access_tokens",
      {}, # no body
      {
        Authorization: "Bearer #{jwt}",
        Accept: "application/vnd.github+json"
      }
    )

    JSON.parse(response.body)["token"]
  rescue RestClient::NotFound, RestClient::Forbidden
    raise InstallationNotFoundError, "GitHub App installation #{installation_id} not found or not accessible"
  end
end
