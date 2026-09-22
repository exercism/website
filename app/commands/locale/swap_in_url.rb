class Locale::SwapInUrl
  include Mandate

  initialize_with :url, :locale

  def call
    uri.dup.tap { |u| u.path = Locale::SwapInPath.(uri.path, locale) }.to_s.delete_suffix("/")
  end

  private
  memoize
  def uri = Addressable::URI.parse(url)
end
