# Records the answers to the sign-up questions. People answer them on the
# sign-up page, or on the onboarding page if they created their account
# through GitHub without seeing them. Both arrive as form params, so
# anything that isn't a known seniority or an active track is ignored.
class User::SetSignUpAnswers
  include Mandate

  initialize_with :user, seniority: nil, sign_up_track_slug: nil

  def call
    attrs = {}
    attrs[:seniority] = seniority.to_s if User::Data.seniorities.key?(seniority.to_s)
    attrs[:sign_up_track_id] = sign_up_track.id if sign_up_track
    return if attrs.empty?

    user.data.update!(attrs)
  end

  private
  memoize
  def sign_up_track
    return nil if sign_up_track_slug.blank?

    Track.active.find_by(slug: sign_up_track_slug.to_s)
  end
end
