class Locale::Direction
  include Mandate

  RTL_LANGUAGES = %w[ar dv fa he ku ps sd ug ur yi].freeze

  initialize_with :locale

  def call = RTL_LANGUAGES.include?(locale.to_s.split("-").first) ? "rtl" : "ltr"
end
