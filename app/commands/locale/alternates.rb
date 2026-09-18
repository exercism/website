class Locale::Alternates
  include Mandate

  # hreflang ignores UN M.49 regions such as 419, so those locales are declared by language alone.
  HREFLANG = { "es-419" => "es" }.freeze

  initialize_with :url

  def call
    return {} if I18n.available_locales.one?

    { "x-default" => url_for(I18n.default_locale) }.merge(
      I18n.available_locales.to_h { |locale| [hreflang(locale), url_for(locale)] }
    )
  end

  private
  def hreflang(locale) = HREFLANG.fetch(locale.to_s, locale.to_s)

  def url_for(locale) = Locale::SwapInUrl.(url, locale)
end
