require 'json'

# config/i18n.json is the single source of truth for locale routing, read by the
# Cloudflare Worker in cloudflare/locale-redirect as well, so the two agree.
module LocaleConfig
  CONFIG = JSON.parse(File.read(File.expand_path('../config/i18n.json', __dir__))).freeze

  DEFAULT = CONFIG['default'].to_sym
  SERVED = CONFIG['served'].map(&:to_sym).freeze
  PUBLIC_SECTIONS = CONFIG['public_sections'].map(&:freeze).freeze
  PUBLIC_PAGES = CONFIG['public_pages'].map(&:freeze).freeze
  VARIANTS = CONFIG['variants'].transform_values { |variant| variant.transform_keys(&:to_sym).freeze }.freeze
end
