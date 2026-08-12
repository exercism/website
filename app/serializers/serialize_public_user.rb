class SerializePublicUser
  include Mandate

  initialize_with :user

  def call
    {
      handle: user.handle,
      avatar_url: user.avatar_url,
      flair: user.flair,
      has_profile: user.profile?,
      reputation: {
        total: user.formatted_reputation,
        tracks: track_reputations
      }
    }
  end

  private
  # One grouped query for every track at once, rather than
  # User#reputation_for_track's live SUM per track. This is covered by the
  # rep_all_values_covering (user_id, track_id, value) index.
  def track_reputations
    sums = User::ReputationToken.
      where(user_id: user.id).
      where.not(track_id: nil).
      group(:track_id).
      sum(:value)

    return {} if sums.blank?

    Track.where(id: sums.keys).pluck(:id, :slug).
      each_with_object({}) { |(id, slug), h| h[slug] = sums[id] }
  end
end
