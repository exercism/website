module LocaleUrlOptions
  # The prefix comes from Current.url_locale, never from I18n.locale: a
  # signed-in user reads the site in their own locale on unprefixed URLs.
  def self.ambient
    locale = Current.url_locale
    locale.to_s unless locale.blank? || locale.to_sym == I18n.default_locale
  end

  module RouteSet
    def url_for(options, route_name = nil, *args)
      if route_name
        scoped = named_routes[route_name]&.parts&.include?(:locale)
        # Rails appends an unknown :locale to an unscoped route as ?locale=hu
        options = scoped ? { locale: LocaleUrlOptions.ambient }.merge(options) : options.except(:locale)
      end

      super
    end
  end

  # Without this, track_path(track) fills :locale positionally and becomes /<track>/tracks
  module UrlHelper
    def handle_positional_args(controller_options, inner_options, args, result, path_params)
      super(controller_options, inner_options, args, result, path_params - [:locale])
    end
  end
end

ActionDispatch::Routing::RouteSet.prepend(LocaleUrlOptions::RouteSet)
ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper.prepend(LocaleUrlOptions::UrlHelper)

# Signing someone in mid-request (the sign-in form, OAuth, an API token) makes
# them a signed-in user from then on, so their redirects and links are
# unprefixed too.
Warden::Manager.after_set_user do
  Current.url_locale = nil
end
