class Localization::Text::GenerateKey
  include Mandate

  initialize_with :type, :text

  def call
    "#{type}.#{digest}"
  end

  memoize
  def digest = Digest::SHA256.hexdigest(text)
end
