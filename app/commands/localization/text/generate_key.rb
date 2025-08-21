class Localization::Text::GenerateKey
  include Mandate

  initialize_with :text

  def call
    raise ArgumentError unless text.present?

    "arbitary.#{digest}"
  end

  memoize
  def digest = Digest::SHA256.hexdigest(text)
end
