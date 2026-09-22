module Jiki
  HOST = "https://jiki.io".freeze

  # Jiki uses the same URL shape as we do: the default locale is unprefixed and
  # every other locale sits under its own segment.
  def self.url(locale = I18n.locale, query: nil)
    segment = locale.to_s == I18n.default_locale.to_s ? nil : locale.to_s
    url = [HOST, segment].compact.join("/")

    query.present? ? "#{url}?#{query}" : url
  end
end
