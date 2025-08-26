# config/initializers/url_defaults.rb
module GlobalUrlOptions
  def default_url_options
    loc = I18n.locale.to_s
    # Always provide the key; use nil for English so the segment is omitted
    { locale: (loc == I18n.default_locale.to_s ? nil : loc) }
  end
end

Rails.configuration.to_prepare do
  Rails.application.routes.named_routes.url_helpers_module.include(GlobalUrlOptions)
end
