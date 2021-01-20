class SerializeReputationTokens
  include Mandate

  initialize_with :tokens

  def call
    {
      tokens: tokens.map do |token|
        serialize_token(token)
      end
    }
  end

  def serialize_token(token)
    {
      value: token.value,
      description: token.description,
      icon_name: token.icon_name,
      link_url: token.link_url,
      awarded_at: token.created_at.iso8601
    }
  end
end
