%w[
  api
  exercises
  notifications
  user_activities
  user_reputation_tokens
  site_updates
  communication_preferences
].each do |category|
  I18n.load_path += Dir[Rails.root.join('config', 'locales', category, '*.{rb,yml}')]
end

# rails-i18n loads files only under an available locale's own name. This adds
# the locales the site serves under a different name from rails-i18n's.
I18n.load_path << Rails.root.join('config', 'locales', 'rails_i18n_aliases.rb').to_s

LOCALE_ROUTE_CONSTRAINT = Regexp.union((I18n.available_locales - [I18n.default_locale]).map(&:to_s)).freeze

I18n.backend = TranslationRepo::Backend.new
