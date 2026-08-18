class Captcha::VerifyTurnstileToken
  include Mandate

  SITEVERIFY_URL = "https://challenges.cloudflare.com/turnstile/v0/siteverify".freeze

  initialize_with :token, remote_ip: nil

  def call
    return false if token.blank?

    parsed = JSON.parse(siteverify_response.body)
    return true if parsed["success"]

    Rails.logger.warn("[Turnstile] verification failed: #{parsed['error-codes']}")
    false
  rescue StandardError => e
    # If Cloudflare is unreachable we fail open: blocking real users on a
    # captcha outage is worse than letting the odd bot through here.
    Rails.logger.error("[Turnstile] siteverify error: #{e.class}: #{e.message} - failing open")
    true
  end

  private
  def siteverify_response
    RestClient::Request.execute(
      method: :post,
      url: SITEVERIFY_URL,
      payload: payload.to_json,
      headers: { content_type: :json },
      timeout: 5
    )
  end

  def payload
    { secret: Exercism.secrets.turnstile_secret, response: token }.tap do |data|
      data[:remoteip] = remote_ip if remote_ip.present?
    end
  end
end
