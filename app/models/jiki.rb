module Jiki
  HOST = "https://jiki.io".freeze
  UTM_SOURCE = "exercism".freeze

  # Every link from Exercism to Jiki goes through this method.
  #
  # Jiki uses the same URL shape as we do: the default locale is unprefixed and
  # every other locale sits under its own segment.
  #
  # Jiki's analytics read utm_source, utm_medium and utm_content from the
  # landing URL. The medium names where the link sits (e.g. "nav" or "footer"),
  # and the optional content tells apart variants of one placement.
  def self.url(locale = I18n.locale, medium:, path: nil, content: nil)
    segment = locale.to_s == I18n.default_locale.to_s ? nil : locale.to_s
    url = [HOST, segment, path&.delete_prefix("/")].compact.join("/")

    params = { utm_source: UTM_SOURCE, utm_medium: medium, utm_content: content }.compact
    "#{url}?#{URI.encode_www_form(params)}"
  end
end
