module LocaleUrlOptions
  def self.ambient = I18n.locale == I18n.default_locale ? nil : I18n.locale.to_s

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
