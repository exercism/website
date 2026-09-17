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

# Never derived from the YAML files that happen to be on the load path.
I18n.default_locale = LocaleRoster.default
I18n.available_locales = LocaleRoster.known
