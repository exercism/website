class Localization::Text::GenerateKey
  include Mandate

  initialize_with :text

  def call
    "arbitary.#{digest}"
  end

  memoize
  def digest = Digest::SHA256.hexdigest(text)
end
