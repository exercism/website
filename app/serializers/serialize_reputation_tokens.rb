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
    if token.track
      track_hash = {
        title: token.track.title,
        icon_name: token.track.icon_name
      }
    end

    {
      value: token.value,
      description: token.description,
      icon_name: token.icon_name,
      internal_link: token.internal_link,
      external_link: token.external_link,
      awarded_at: token.created_at.iso8601,
      track: track_hash
    }
  end
end
