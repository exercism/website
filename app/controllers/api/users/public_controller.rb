# A deliberately anonymous, CDN-cacheable endpoint returning a user's
# identity data (avatar, flair, reputation, profile existence).
#
# It exists so that these values - which change independently of any page
# they appear on - do not need to be baked into cached HTML.
#
# CRITICAL: this response must never carry a Set-Cookie header, or Cloudflare
# will refuse to cache it. Hence the session being skipped explicitly below,
# on top of ApplicationController's skip_empty_session_cookie.
class API::Users::PublicController < API::BaseController
  skip_before_action :authenticate_user!
  skip_before_action :store_session_variables
  skip_before_action :rate_limit_for_user!
  skip_after_action :set_user_id_cookie

  before_action :skip_session!

  def show
    user = User.find_by(handle: params[:handle])
    return render_404(:user_not_found) if user.blank?

    set_cache_headers!
    render json: SerializePublicUser.(user)
  end

  private
  def skip_session!
    request.session_options[:skip] = true
  end

  def set_cache_headers!
    # Browser TTL matches edge TTL deliberately: nothing purges this endpoint,
    # so the edge TTL is the floor on staleness anyway.
    expires_in TTL, public: true, "s-maxage": TTL.to_i
  end

  TTL = 1.hour
  private_constant :TTL
end
