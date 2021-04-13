class SerializeUserReputationToken
  include Mandate

  initialize_with :token

  def call
    token.rendering_data
  end
end
