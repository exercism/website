%w[
  api
  notifications
  user_activities
  user_reputation_tokens
].each do |category|
  I18n.load_path += Dir[Rails.root.join('config', 'locales', category, '*.{rb,yml}')]
end
