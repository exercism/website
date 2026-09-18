class Locale::Alternates
  include Mandate

  # hreflang ignores UN M.49 regions such as 419, so those locales are declared by language alone.
  HREFLANG = { "es-419" => "es" }.freeze

  initialize_with :url

  def call
    return {} if LocaleRoster.production.one?

    { "x-default" => url_for(LocaleRoster.default) }.merge(
      LocaleRoster.production.to_h { |locale| [hreflang(locale), url_for(locale)] }
    )
  end

  private
  def hreflang(locale) = HREFLANG.fetch(locale.to_s, locale.to_s)

  def url_for(locale)
    uri.dup.tap { |u| u.path = Locale::SwapInPath.(uri.path, locale) }.to_s.delete_suffix("/")
  end

  memoize
  def uri = Addressable::URI.parse(url)
end
