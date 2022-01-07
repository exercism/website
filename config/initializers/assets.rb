Rails.application.configure do
  config.assets.version = "1.0"
  config.assets.paths << "app/images"
  config.assets.paths << ".built-assets"
end
