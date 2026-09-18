class Locale::Normalize
  include Mandate

  # TODO(iHiD): OPEN. Whether split variants such as es-419/es-ES will ship.
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

  def initialize(tag, locales = I18n.available_locales)
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
