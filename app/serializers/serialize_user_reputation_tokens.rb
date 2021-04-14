class SerializeUserReputationTokens
  include Mandate

  def initialize(tokens)
    @tokens = tokens
  end

  def call
    tokens.map do |token|
      SerializeUserReputationToken.(token)
    end
  end

  private
  attr_reader :tokens
end
