db_file = Rails.env.production? ?
  File.join('/usr', 'share', 'GeoIP', 'GeoLite2-City.mmdb') :
  Rails.root.join('vendor', 'GeoLite2-City.mmdb')

# rubocop:disable Naming/VariableNumber
Geocoder.configure(
  ip_lookup: :geoip2,
  geoip2: {
    # The country database is the smallest available database that allows us to
    # map an IP address to a country code
    file: ENV.fetch('GEOIP_FILE', db_file)
  },

  # Use Rails' own cache
  cache: Geocoder::CacheStore::Generic.new(Rails.cache, {}),

  # Lowest possible value; should never be hit due to using file-based lookup
  timeout: 1
)
# rubocop:enable Naming/VariableNumber
