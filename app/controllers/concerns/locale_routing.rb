module LocaleRouting
  extend ActiveSupport::Concern
  extend Mandate::Memoize
  include LocaleSupport

  included do
    # Order matters:
    before_action :maybe_redirect_user_to_correct_locale!
    before_action :maybe_redirect_en_to_naked!
    around_action :switch_locale!
  end

  def maybe_redirect_user_to_correct_locale!
    return unless user_signed_in?       # Only signed in users.
    return unless html_request?         # Only HTML requests.
    return unless request.get?          # Only GETs
    return if locale_from_path.present? # Already on /xx/ path
    return if params[LocaleSupport::QUERY_PARAM].present? # guard against loops (localStorage or link adds this once)

    user_locale = current_user.locale
    return unless user_locale.present?

    user_locale = normalize_locale(user_locale)
    return if user_locale.to_s.starts_with?("en")

    response.headers['Cache-Control'] = 'no-store'
    redirect_to path_for_locale(user_locale, request.fullpath), allow_other_host: false, status: :found
  end

  def maybe_redirect_en_to_naked!
    return unless html_request?             # Only HTML requests.
    return unless request.get?              # Only GETs

    locale = locale_from_path
    return unless locale == "en"

    redirect_to request.fullpath.sub(%r{^/en}, ''), allow_other_host: false, status: :found
  end

  def switch_locale!(&action)
    locale = specified_locale || default_locale
    I18n.with_locale(locale, &action)
  end

  # Build a locale-scoped URL preserving the rest of the path/query
  def path_for_locale(loc, fullpath)
    uri = begin
      Addressable::URI.parse(fullpath)
    rescue StandardError
      nil
    end
    if uri
      path = uri.path
      query = uri.query
    else
      path  = fullpath
      query = nil
    end
    # Strip any existing leading locale segment before adding new one
    segments = path.to_s.sub(%r{^/}, '').split('/') # Remove leading slash and split into segments

    # If we have a locale, remove it.
    path_locale = normalize_locale(segments[0])
    segments.shift if path_locale.present?
    path = "/#{segments.join('/')}"

    new_path = "/#{loc}#{path}".gsub(%r{/{2,}}, "/")
    new_path += "?#{query}" if query.present?

    # Add one-time loop-breaker for server-side redirects only
    unless new_path.include?("#{LocaleSupport::QUERY_PARAM}=")
      new_path += (query.present? ? "&" : "?") + "#{LocaleSupport::QUERY_PARAM}=1"
    end
    new_path
  end
end
