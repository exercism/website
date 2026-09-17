require 'json'

# The one list of locales the site knows about. It is read from
# config/locale_roster.json, which app/javascript/utils/locale-roster.ts
# also imports, so Ruby and JavaScript can never disagree.
#
# A locale's status is one of:
#   production: served to everyone, indexed, and must never show English.
#   wip:        routable for staff and that locale's translators only.
#   planned:    known, but not served anywhere.
module LocaleRoster
  STATUSES = %w[production wip planned].freeze
  PATH = File.expand_path('../config/locale_roster.json', __dir__)

  class << self
    def default = data[:default]
    def known = data[:known]
    def production = data[:production]
    def wip = data[:wip]

    # The locales this environment routes. Tests run in English
    # unless they opt in via with_served_locales.
    def served
      return [default] if Rails.env.test?

      production | wip
    end

    def known?(locale) = known.include?(locale&.to_sym)
    def served?(locale) = served.include?(locale&.to_sym)
    def production?(locale) = production.include?(locale&.to_sym)
    def wip?(locale) = served?(locale) && !production?(locale)
    def default?(locale) = locale&.to_sym == default

    # The URL prefix for a locale. English is naked, so it has none.
    def path_segment(locale)
      return nil if locale.blank? || default?(locale)

      locale.to_s
    end

    # Matches the locale path segment. English is never prefixed.
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
