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
