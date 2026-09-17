# Every generated URL carries the ambient locale, whoever generates it:
# a controller, a mailer, Exercism::Routes in a job, or a test.
# English is naked, so its URLs get no prefix.
module LocaleUrlOptions
  def self.ambient = LocaleRoster.path_segment(I18n.locale)

  module RouteSet
    def url_for(options, route_name = nil, *args)
      if route_name
        scoped = named_routes[route_name]&.parts&.include?(:locale)
        # Unscoped routes (api, webhooks, omniauth callbacks...) must not
        # leak the locale as ?locale=hu
        options = scoped ? { locale: LocaleUrlOptions.ambient }.merge(options) : options.except(:locale)
      end

      super
    end
  end

  # The optional :locale segment is never filled positionally, or
  # track_path(track) would become /<track>/tracks
  module UrlHelper
    def handle_positional_args(controller_options, inner_options, args, result, path_params)
      super(controller_options, inner_options, args, result, path_params - [:locale])
    end
  end
end

ActionDispatch::Routing::RouteSet.prepend(LocaleUrlOptions::RouteSet)
ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper.prepend(LocaleUrlOptions::UrlHelper)
