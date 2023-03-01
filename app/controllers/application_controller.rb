class ApplicationController < ActionController::Base
  extend Mandate::Memoize
  include Turbo::Redirection
  include Turbo::CustomFrameRequest
  include BodyClassConcern

  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :ensure_onboarded!
  around_action :mark_notifications_as_read!
  before_action :set_request_context
  after_action :set_body_class_header
  after_action :set_csp_header
  after_action :updated_last_visited_on!

  def process_action(*args)
    super
  rescue ActionDispatch::Http::MimeNegotiation::InvalidType,
         ActionDispatch::Http::Parameters::ParseError => e
    request.headers['Content-Type'] = 'application/json'
    render status: :bad_request, json: { errors: [e.message] }
  end

  def ensure_onboarded!
    return unless user_signed_in?
    return if current_user.onboarded?

    redirect_to user_onboarding_path
  end

  def ensure_admin!
    return if current_user&.admin?

    redirect_to maintaining_root_path
  end

  # We want to mark relevant notifications as read, but we don't
  # care about doing this before the rest of the action is run, so we
  # use a promise to kick it off async. However, we do want it to finish
  # before we send the response (which loads notifications async) so we
  # wait for the promise to finish before leaving this block.
  def mark_notifications_as_read!
    future = Concurrent::Promises.future do
      Rails.application.executor.wrap do
        next if devise_controller?
        next unless user_signed_in?
        next unless request.get?
        next unless is_navigational_format?
        next if request.xhr?

        User::Notification::MarkRelevantAsRead.(current_user, request.path)
        User::Notification::MarkBatchAsRead.(current_user, [params[:notification_uuid]]) if params[:notification_uuid].present?
      end
    end

    yield
  ensure
    future.value
  end

  def ensure_mentor!
    return if current_user&.mentor?

    redirect_to mentoring_path
  end

  def ensure_supermentor!
    return if current_user&.supermentor?

    redirect_to mentoring_path
  end

  def ensure_not_mentor!
    return unless current_user&.mentor?

    redirect_to mentoring_inbox_path
  end

  def set_request_context
    Exercism.request_context = { remote_ip: request.remote_ip }
  end

  # rubocop:disable Lint/PercentStringArray
  def csp_policy
    websockets = "ws://#{Rails.env.production? ? 'exercism.org' : 'local.exercism.io:3334'}"
    stripe = "https://js.stripe.com"
    captcha = %w[https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/]
    google_fonts_font = "https://fonts.gstatic.com"
    google_fonts_css = "https://fonts.googleapis.com"
    fontawesome = "https://maxcdn.bootstrapcdn.com"
    spellchecker = "https://cdn.jsdelivr.net"

    default = %w['self' https://exercism.org https://api.exercism.org https://d24y9kuxp2d7l2.cloudfront.net]
    default << "127.0.0.1" if Rails.env.test?

    {
      default:,
      connect: ["'self'", websockets, spellchecker],
      img: %w['self' data: https://*],
      media: %w[*],
      script: default + [stripe, spellchecker, *captcha],
      frame: [stripe, *captcha],
      font: [google_fonts_font, fontawesome],
      style: default + ["'unsafe-inline'", google_fonts_css, fontawesome],
      child: %w['none']

    }.map do |type, domains|
      "#{type}-src #{domains.join(' ')}"
    end.join("; ")
  end
  helper_method :csp_policy
  # rubocop:enable Lint/PercentStringArray

  private
  def set_body_class_header
    response.set_header("Exercism-Body-Class", body_class)
  end

  def set_csp_header
    response.set_header('Content-Security-Policy-Report-Only', csp_policy)
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? &&
      request.fullpath != '/site.webmanifest'
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def updated_last_visited_on!
    return unless user_signed_in?
    return unless request.format == :html
    return if current_user.last_visited_on == Time.zone.today

    current_user.update(last_visited_on: Time.zone.today)
  end

  def render_template_as_json
    respond_to do |format|
      format.json do
        render json: {
          html: render_to_string(
            template: [namespace_name, controller_name, action_name].compact.join('/'),
            layout: false,
            formats: [:html]
          )
        }
      end
      format.html do
      end
    end
  end

  def render_404
    render(
      template: 'errors/not_found',
      layout: true,
      status: :not_found
    )
  end
end
