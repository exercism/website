# Reads the first-touch attribution cookie written by
# app/javascript/utils/signup-attribution.ts. The browser controls the
# cookie, so only known keys with short string values are kept.
class User::ParseSignupAttribution
  include Mandate

  initialize_with :raw

  def call
    return {} if raw.blank?

    data = JSON.parse(raw)
    return {} unless data.is_a?(Hash)

    data.slice(*KEYS).
      select { |_, value| value.is_a?(String) && value.present? }.
      transform_values { |value| value[0, MAX_LENGTH] }
  rescue JSON::ParserError
    {}
  end

  KEYS = %w[referrer landing_path utm_source utm_medium utm_campaign utm_content].freeze
  MAX_LENGTH = 200
  private_constant :KEYS, :MAX_LENGTH
end
