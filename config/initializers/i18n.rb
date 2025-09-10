# frozen_string_literal: true

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

#
#
#
#
# module I18n
#   class ExercismBackend
#     include Base
#
#     # Mutex to ensure that concurrent translations loading will be thread-safe
#     MUTEX = Mutex.new
#
#     def reload!
#       @initialized = false
#       @translations = nil
#       super
#     end
#
#     def eager_load!
#       init_translations unless initialized?
#       super
#     end
#
#     def translations(do_init: false)
#       # To avoid returning empty translations,
#       # call `init_translations`
#       init_translations if do_init && !initialized?
#
#       @translations ||= Concurrent::Hash.new do |h, k|
#         MUTEX.synchronize do
#           h[k] = Concurrent::Hash.new
#         end
#       end
#     end
#
#     def translate(locale, key, options = {})
#       value = Localization::Translation.lookup(locale, key, options.merge(use_cache: true))
#       return value if value.present?
#
#       throw(:exception, I18n::MissingTranslationData.new(locale, key, options))
#     end
#
#     # I had this LOC before, but I removed it to hardcode the locales.
#     # We don't actually want to do this as we have WIP ones.
#     # Localization::Translation.distinct.pluck(:locale).map(&:to_sym)
#     def available_locales = %i[en hu nl de pt pt-BR]
#     def wip_locales = %i[es]
#     def default_locale = :en
#
#       protected
#
#       def init_translations
#         load_translations
#         @initialized = true
#       end
#
#       # Looks up a translation from the translations hash. Returns nil if
#       # either key is nil, or locale, scope or key do not exist as a key in the
#       # nested translations hash. Splits keys or scopes containing dots
#       # into multiple keys, i.e. <tt>currency.format</tt> is regarded the same as
#       # <tt>%w(currency format)</tt>.
#       def lookup(locale, key, scope = [], options = EMPTY_HASH)
#         init_translations unless initialized?
#         keys = I18n.normalize_keys(locale, key, scope, options[:separator])
#
#         keys.inject(translations) do |result, _key|
#           return nil unless result.is_a?(Hash)
#           unless result.has_key?(_key)
#             _key = _key.to_s.to_sym
#             return nil unless result.has_key?(_key)
#           end
#           result = result[_key]
#           result = resolve_entry(locale, _key, result, Utils.except(options.merge(:scope => nil), :count)) if result.is_a?(Symbol)
#           result
#         end
#       end
#     end
#
#     include Implementation
#   end
#
#   def self.wip_locales = ExercismI18nBackend.new.wip_locales
# end
#
# Put this in front of the existing backend.
# I18n.backend = I18n::Backend::Chain.new(
#   I18n.Backend::Exercism.new,
#   I18n.backend
# )
# nd
