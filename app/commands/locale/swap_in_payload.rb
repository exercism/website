# Rewrites the URLs in a cached payload so they point at one locale's pages.
# A payload is cached once, in the default locale, so the URLs it holds are the
# canonical unprefixed ones and a non-default locale only needs the prefix
# adding on the way out.
#
# The route set decides which URLs those are, the way
# config/initializers/url_defaults.rb does when it generates them, so a URL
# added to a payload later is localised (or left alone) on its own route's
# terms rather than against a list kept here.
class Locale::SwapInPayload
  include Mandate

  initialize_with :payload, :locale

  def call
    return payload if locale.to_sym == I18n.default_locale

    swap(payload)
  end

  private
  def swap(node)
    case node
    when Hash then node.transform_values { |value| swap(value) }
    when Array then node.map { |value| swap(value) }
    when String then swap_url(node)
    else node
    end
  end

  def swap_url(url)
    return url unless url.start_with?("#{origin}/")
    return url unless locale_scoped?(url)

    Locale::SwapInUrl.(url, locale)
  end

  # A payload holds one path many times over while its query strings differ, so
  # the answer is cached against the path alone.
  def locale_scoped?(url)
    path = url.delete_prefix(origin).split("?").first
    scoped.fetch(path) { scoped[path] = route_for(url)&.parts&.include?(:locale) || false }
  end

  def route_for(url)
    request = ActionDispatch::Request.new(Rack::MockRequest.env_for(url))
    Rails.application.routes.router.recognize(request) { |route, _params| return route }
    nil
  end

  memoize
  def scoped = {}

  # Every URL the app generates for itself starts with this.
  memoize
  def origin = Exercism::Routes.host.delete_suffix("/")
end
