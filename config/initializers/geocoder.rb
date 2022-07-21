# rubocop:disable Naming/VariableNumber
Geocoder.configure(
  timeout: 1, # in seconds
  ip_lookup: :geoip2,
  geoip2: {
    file: File.join('/usr', 'share', 'GeoIP', 'GeoLite2-City.mmdb')
  },
  cache: Redis.new
  # cache_options: {
  #   expiration: 2.days,
  #   prefix: 'geocoder:'
  # }
)
# rubocop:enable Naming/VariableNumber
