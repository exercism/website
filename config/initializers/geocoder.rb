# rubocop:disable Naming/VariableNumber
Geocoder.configure(
  timeout: 1, # in seconds
  ip_lookup: :geoip2,
  geoip2: {
    file: ENV.fetch("GEOIP_FILE", '/usr/share/GeoIP/GeoLite2-Country.mmdb')
  },
  cache: Redis.new
  # cache_options: {
  #   expiration: 2.days,
  #   prefix: 'geocoder:'
  # }
)
# rubocop:enable Naming/VariableNumber
