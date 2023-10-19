class Exercise::Representation::Recache
  include Mandate

  initialize_with :representation, last_submitted_at: nil

  def call
    update_model!
    Exercise::Representation::UpdateNumSubmissions.defer(representation)
    Exercise::Representation::SyncToSearchIndex.defer(representation)
  end

  private
  def update_model!
    attrs = {
      oldest_solution:,
      prestigious_solution:,
      num_published_solutions: representation.published_solutions.count
    }

    attrs[:last_submitted_at] = last_submitted_at if last_submitted_at
    representation.update!(attrs)
  end

  def oldest_solution
    representation.published_solutions.
      where.not(user_id: User::GHOST_USER_ID).
      first
  end

  def prestigious_solution
    user_ids = representation.published_solutions.
      where.not(user_id: User::GHOST_USER_ID).
      select(:user_id)
    return nil unless user_ids

    user_id = User::ReputationPeriod.where(
      period: :forever,
      category: :any,
      about: :track,
      track_id: representation.track_id,
      user_id: user_ids
    ).order(reputation: :desc).pick(:user_id)

    return oldest_solution unless user_id

    representation.published_solutions.find_by!(user_id:)
  end
end
