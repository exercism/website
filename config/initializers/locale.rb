%w[
  api
  auth
  notifications
  user_activities
].each do |category|
  I18n.load_path += Dir[Rails.root.join('config', 'locales', category, '*.{rb,yml}')]
end
