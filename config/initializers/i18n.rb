I18n.define_singleton_method(:wip_locales) do
  %i[hu]
end

=begin
require 'i18n/backend/base'
require 'i18n/backend/simple'

module I18n
  module Backend
    class Exercism < Simple
      def self.wip_locales = %i[es hu nl de pt pt-BR]
      def available_locales = %i[en]
      def default_locale = :en

      def load_translations
        rows = Localization::Translation.pluck(:locale, :key, :value)

        rows.group_by(&:first).each do |locale, group|
          merged = {}

          group.each do |(_, key, value)|
            keys   = key.split(".")
            nested = build_nested_hash(keys, value)
            Utils.deep_merge!(merged, nested)
          end

          store_translations(locale.to_sym, merged)
        end
      end

      private
      def build_nested_hash(keys, value)
        keys.reverse.inject(value) { |acc, key| { key.to_sym => acc } }
      end
    end
  end
end

# Put this in front of the existing backend.
I18n.backend = I18n::Backend::Chain.new(
  I18n::Backend::Exercism.new,
  I18n.backend
)
I18n.define_singleton_method(:wip_locales) do
  I18n::Backend::Exercism.wip_locales
end
=end