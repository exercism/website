module LocaleRouting
  extend ActiveSupport::Concern
  include LocaleSupport

  QUERY_PARAM = :_lr # Loop-breaker for one-time redirects

  included do
    # Order matters:
    before_action :maybe_redirect_to_locale_path # one-time redirect for humans only
    around_action :switch_locale
  end

  # 1) Redirect anonymous humans to their locale path (one-time) — no cookies.
  #    Uses Accept-Language. Never redirect bots. Never redirect non-HTML/unsafe requests.
  def maybe_redirect_to_locale_path
    return unless html_request?
    return unless request.get?          # only GETs
    return if locale_from_path.present? # already on /xx/ path
    return if request.bot?              # Don't redirect bots
    return if params[QUERY_PARAM].present? # guard against loops (localStorage or link adds this once)

    # If user is logged in, honor their saved locale; else Accept-Language
    target = desired_locale
    return if target == default_locale # English remains at root

    # Build target path with same resource + query
    path = request.path.dup
    return '/' if path.blank?

    redirect_to path_for_locale(target, request.fullpath), allow_other_host: false, status: :found

    # Critical: don't let CDNs cache this redirect
    response.headers['Cache-Control'] = 'no-store'
  end

  # 2) Wrap each request in I18n.with_locale
  def switch_locale(&action)
    locale = locale_from_path || default_locale
    I18n.with_locale(locale, &action)
  end

  # Locale we want to serve:
  #  1) path locale (if any)
  #  2) logged-in user's saved locale
  #  3) Accept-Language best fit
  #  4) default
  def desired_locale
    return locale_from_path if locale_from_path.present?
    return normalize_locale(current_user.locale) if current_user&.locale.present?

    best_locale_from_accept_language || default_locale
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
    new_path += (query.present? ? "&" : "?") + "#{QUERY_PARAM}=1" unless new_path.include?("#{QUERY_PARAM}=")
    new_path
  end
end
