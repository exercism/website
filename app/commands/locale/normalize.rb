# Maps a language tag (from a browser, a stored preference, or anywhere
# else) onto one of our locales, or nil. Regional variants never collapse
# into each other: a tag resolves to the variant its region belongs to, and
# to nothing if we don't have that variant.
class Locale::Normalize
  include Mandate

  # Which variant a tag gets when we ship more than one for its language.
  # Chromium sends es-419, Firefox and Safari send es-CL or es-AR, and
  # plenty of browsers send a bare pt or zh.
  #   bare:     a tag with no script or region
  #   scripts:  script subtag => variant (checked before the region)
  #   regions:  region subtag => variant
  #   fallback: any other region
  VARIANTS = {
    "es" => { bare: "es-419", regions: { "ES" => "es-ES", "419" => "es-419" }, fallback: "es-419" },
    "pt" => { bare: "pt-BR", regions: { "BR" => "pt-BR" }, fallback: "pt-PT" },
    "zh" => {
      bare: "zh-CN",
      scripts: { "Hans" => "zh-CN", "Hant" => "zh-TW" },
      regions: { "TW" => "zh-TW", "HK" => "zh-TW", "MO" => "zh-TW" },
      fallback: "zh-CN"
    }
  }.freeze

  def initialize(tag, locales = LocaleRoster.served)
    @tag = tag.to_s.tr('_', '-')
    @locales = locales.map(&:to_s)
  end

  def call
    return if language.blank?

    [canonical, variant, language].compact.find { |l| locales.include?(l) }&.to_sym
  end

  private
  attr_reader :tag, :locales

  def canonical = [language, region].compact.join("-")

  # Only consulted while we ship a variant of this language. If we ship
  # a plain "es", every Spanish tag falls through to it.
  def variant
    return unless config && locales.any? { |l| l.start_with?("#{language}-") }

    config.dig(:scripts, script) || (region ? config[:regions].fetch(region, config[:fallback]) : config[:bare])
  end

  def config = VARIANTS[language]

  memoize
  def subtags = tag.split("-")

  def language = subtags.first.to_s.downcase.presence
  def script = subtags.drop(1).find { |s| s.match?(/\A[A-Za-z]{4}\z/) }&.capitalize
  def region = subtags.drop(1).find { |s| s.match?(/\A([A-Za-z]{2}|\d{3})\z/) }&.upcase
end
