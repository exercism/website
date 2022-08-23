class SerializeUserReputationTokens
  include Mandate

  initialize_with :tokens

  def call
    tokens.map do |token|
      SerializeUserReputationToken.(token)
    end
  end
end
