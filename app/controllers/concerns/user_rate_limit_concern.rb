module UserRateLimitConcern
  extend ActiveSupport::Concern
  extend Mandate::Memoize

  def rate_limit_for_user!
    return if devise_controller?
    return unless user_signed_in?

    within = 1.minute
    max = 60
    key = "rate-limit:#{controller_path}:#{current_user.id}"
    count = Rails.cache.increment(key, 1, expires_in: within)
    return unless count && count > max

    if request.xhr? || controller_path.starts_with?("api/")
      head :too_many_requests
    else
      @status_code = 429
      @error_title = "You've gone too fast!"
      @errror_message = ""
      render template: "errors/too_many_requests"
    end
  end
end
