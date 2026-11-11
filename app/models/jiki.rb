module Jiki
  HOST = "https://jiki.io".freeze
  UTM_SOURCE = "exercism".freeze

  # Jiki uses the same URL shape as we do: the default locale is unprefixed and
  # every other locale sits under its own segment.
  #
  # Pass a medium for any link a user clicks. Jiki's analytics read utm_source
  # and utm_medium from the landing URL, so the medium should name the placement
  # (e.g. "nav" or "footer").
  def self.url(locale = I18n.locale, path: nil, query: nil, medium: nil)
    segment = locale.to_s == I18n.default_locale.to_s ? nil : locale.to_s
    url = [HOST, segment, path&.delete_prefix("/")].compact.join("/")
    url = "#{url}?#{query}" if query.present?

    medium.present? ? with_utm(url, medium) : url
  end

  # Adds utm_source and utm_medium to any Jiki URL. It keeps an existing query
  # string and fragment, and it leaves any utm_source or utm_medium already in
  # the URL untouched.
  def self.with_utm(url, medium)
    uri = URI.parse(url)
    params = URI.decode_www_form(uri.query.to_s)
    keys = params.map(&:first)
    params << ["utm_source", UTM_SOURCE] unless keys.include?("utm_source")
    params << ["utm_medium", medium.to_s] unless keys.include?("utm_medium")
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end
end
