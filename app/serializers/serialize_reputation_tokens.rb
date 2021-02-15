class SerializeReputationTokens
  include Mandate

  initialize_with :tokens

  def call
    tokens.map(&:rendering_data)
  end
end
