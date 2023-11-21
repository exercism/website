class ApplicationController < ActionController::Base
  extend Mandate::Memoize
  include Turbo::Redirection
  include Turbo::CustomFrameRequest
  include BodyClassConcern

  # around_action :set_log_level
  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user!
  before_action :ensure_onboarded!
  around_action :mark_notifications_as_read!
  before_action :set_request_context
  after_action :set_body_class_header
  after_action :set_csp_header
  after_action :set_link_header
  after_action :updated_last_visited_on!

  def process_action(*args)
    super
  rescue ActionDispatch::Http::MimeNegotiation::InvalidType,
         ActionDispatch::Http::Parameters::ParseError => e
    request.headers['Content-Type'] = 'application/json'
    render status: :bad_request, json: { errors: [e.message] }
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def current_user
    return super if Rails.env.production?

    # Deal with things that bullet complains should be
    # n+1'd by just loading them here.
    @__bullet_current_user ||=
      Exercism.without_bullet do
        super.tap do |u|
          u&.avatar_url
          u&.profile?
        end
      end
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def ensure_onboarded!
    return unless user_signed_in?
    return if current_user.onboarded?

    redirect_to user_onboarding_path
  end

  def ensure_admin!
    return if current_user&.admin?

    redirect_to maintaining_root_path
  end

  def ensure_maintainer!
    return if current_user&.maintainer?

    redirect_to root_path
  end

  def ensure_staff!
    return if current_user&.staff?

    redirect_to maintaining_root_path
  end

  def ensure_iHiD! # rubocop:disable Naming/MethodName
    return true if Rails.env.development?
    return true if current_user&.id == User::IHID_USER_ID

    redirect_to root_path
  end

  def ensure_trainer!
    return if current_user&.trainer?(@track)

    redirect_to training_data_external_path
  end

  # We want to mark relevant notifications as read, but we don't
  # care about doing this before the rest of the action is run, so we
  # use a promise to kick it off async. However, we do want it to finish
  # before we send the response (which loads notifications async) so we
  # wait for the promise to finish before leaving this block.
  def mark_notifications_as_read!
    return yield if devise_controller?
    return yield unless user_signed_in?
    return yield unless request.get?
    return yield unless is_navigational_format?
    return yield if request.xhr?

    begin
      future = Concurrent::Promises.future do
        Rails.application.executor.wrap do
          User::Notification::MarkRelevantAsRead.(current_user, request.path)
          User::Notification::MarkBatchAsRead.(current_user, [params[:notification_uuid]]) if params[:notification_uuid].present?
        end
      end

      yield
    ensure
      future.value
    end
  end

  def ensure_mentor!
    return if current_user&.mentor?

    redirect_to mentoring_path
  end

  def ensure_automator!
    return if current_user&.staff?
    return if current_user&.track_mentorships&.automator&.exists?

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
    fontawesome = "https://maxcdn.bootstrapcdn.com"
    spellchecker = "https://cdn.jsdelivr.net"
    bugsnag = "https://sessions.bugsnag.com/"

    default = %w['self' https://exercism.org https://api.exercism.org https://assets.exercism.org]
    default << "127.0.0.1" if Rails.env.test?

    {
      default:,
      connect: ["'self'", websockets, spellchecker, bugsnag],
      img: %w['self' data: https://*],
      media: %w[*],
      script: default + [stripe, spellchecker, *captcha],
      frame: [stripe, *captcha],
      font: default + [fontawesome],
      style: default + ["'unsafe-inline'", fontawesome],
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

  def set_log_level
    return yield if Rails.env.development?

    begin
      return yield if devise_controller?
      return yield unless user_signed_in?
      return yield unless current_user.admin? || current_user.handle == "bobahop"

      ActiveRecord.verbose_query_logs = true
      Rails.logger.level = :debug

      yield
    ensure
      ActiveRecord.verbose_query_logs = false
      Rails.logger.level = :info
    end
  end

  def set_csp_header
    return unless Rails.env.production?

    response.set_header('Content-Security-Policy-Report-Only', csp_policy)
  end

  def set_link_header
    links = [
      LinkHeaderLink.new('website.css', rel: :preload, as: :style),
      LinkHeaderLink.new('poppins-v20-latin-regular.woff2', rel: :preload, as: :font, type: "font/woff2", crossorigin: :anonymous),
      LinkHeaderLink.new('poppins-v20-latin-600.woff2', rel: :preload, as: :font, type: "font/woff2", crossorigin: :anonymous)
    ]
    response.set_header('Link', links.map(&:to_s).join(","))
  end
  LinkHeaderLink = Struct.new(:asset, :attrs) do
    include Propshaft::Helper
    def to_s
      url = "#{Rails.application.config.action_controller.asset_host}#{compute_asset_path(asset)}"
      "<#{url}>; #{attrs.map { |k, v| %(#{k}="#{v}") }.join('; ')}"
    end
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

    User::Data::SafeUpdate.(current_user) do |data|
      data.last_visited_on = Time.zone.today
    end
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
