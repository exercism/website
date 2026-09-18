require 'json'

module LocaleRoster
  STATUSES = %w[production wip planned].freeze
  RTL_LANGUAGES = %w[ar dv fa he ku ps sd ug ur yi].freeze
  PATH = File.expand_path('../config/locale_roster.json', __dir__)

  class << self
    def default = data[:default]
    def known = data[:known]
    def production = data[:production]
    def wip = data[:wip]

    def served
      return [default] if Rails.env.test?

      production | wip
    end

    def known?(locale) = known.include?(locale&.to_sym)
    def served?(locale) = served.include?(locale&.to_sym)
    def production?(locale) = production.include?(locale&.to_sym)
    def wip?(locale) = served?(locale) && !production?(locale)
    def default?(locale) = locale&.to_sym == default

    # TODO(iHiD): OPEN. Whether RTL is in scope for launch.
    def direction(locale) = RTL_LANGUAGES.include?(locale.to_s.split("-").first) ? "rtl" : "ltr"

    def path_segment(locale)
      return nil if locale.blank? || default?(locale)

      locale.to_s
    end

    def route_constraint = Regexp.union((known - [default]).map(&:to_s))

    def reload! = @data = nil

    private
    def data = @data ||= load!

    def load!
      json = JSON.parse(File.read(PATH), symbolize_names: true)
      default = json.fetch(:default).to_sym
      by_status = json.fetch(:locales).group_by { |l| l.fetch(:status) }
      unknown = by_status.keys - STATUSES
      raise "Unknown locale status: #{unknown.join(', ')}" if unknown.any?

      locales = ->(status) { by_status.fetch(status, []).map { |l| l.fetch(:code).to_sym } }
      raise "The default locale must be in production" unless locales.('production').include?(default)

      {
        default:,
        known: json[:locales].map { |l| l[:code].to_sym }.freeze,
        production: locales.('production').freeze,
        wip: locales.('wip').freeze
      }.freeze
    end
  end
end
