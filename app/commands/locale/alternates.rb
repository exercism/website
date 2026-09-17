# The reciprocal hreflang map for a page: one absolute URL per production
# locale plus x-default. The same map goes in every variant's <head> and
# in the sitemap, so the two can never drift.
class Locale::Alternates
  include Mandate

  # Search engines only accept an ISO 639-1 language with an optional
  # ISO 3166-1 region. A UN M.49 region such as 419 is silently ignored,
  # so those locales are declared by language alone. Only the hreflang
  # value changes: URLs and <html lang> keep the full code.
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
