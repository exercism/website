# The code sample for the sign-up code check, fetched when someone picks a
# language. It is anonymous and the same for everyone, so it is cacheable at
# the edge. It must never carry a Set-Cookie header, or Cloudflare will refuse
# to cache it, which is why the session is skipped.
class API::Tracks::SignUpSnippetsController < API::BaseController
  skip_before_action :authenticate_user!
  skip_before_action :store_session_variables
  skip_before_action :rate_limit_for_user!

  # People who signed up through GitHub answer the sign-up questions on the
  # onboarding page, before they have accepted the terms.
  skip_before_action :ensure_onboarded!
  skip_after_action :set_user_id_cookie

  # The snippet is code, so it is the same in every locale.
  skip_after_action :set_locale_vary_header

  before_action :skip_session!

  def show
    track = Track.active.find_by(slug: params[:track_slug])
    return render_404(:track_not_found) unless track

    snippet = Track::RetrieveSignUpSnippet.(track)
    return render_404(:track_not_found) if snippet.blank?

    expires_in TTL, public: true, "s-maxage": TTL.to_i
    render json: {
      snippet:,
      highlightjs_language: track.highlightjs_language
    }
  end

  private
  def skip_session!
    request.session_options[:skip] = true
  end

  TTL = 1.hour
  private_constant :TTL
end
