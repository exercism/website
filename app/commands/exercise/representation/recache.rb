class Exercise::Representation::Recache
  include Mandate

  queue_as :solution_processing

  initialize_with :representation, last_submitted_at: nil, force: false

  # rubocop:disable Style/IfUnlessModifier
  # rubocop:disable Style/GuardClause
  def call
    update_model!

    # If the representation has changed, or we're actively specifying a new
    # last_submitted_at (even if it's the same as previous), then we should
    # recaculate num submissions to be safae.
    if representation_changed? || last_submitted_at || force
      Exercise::Representation::UpdateNumSubmissions.defer(representation)
    end

    # If the representation has changed then resync it, else don't waste the cycles.
    if representation_changed? || force
      Exercise::Representation::SyncToSearchIndex.defer(representation)
    end
  end
  # rubocop:enable Style/IfUnlessModifier
  # rubocop:enable Style/GuardClause

  private
  delegate :exercise, to: :representation

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
    user_id = User::ReputationToken.where(
      track_id: exercise.track_id,
      user_id: representation.published_solutions.select(:user_id)
    ).
      group(:user_id).
      select("user_id, SUM(value) as total").
      order('total DESC').
      first&.user_id

    return oldest_solution unless user_id

    representation.published_solutions.find_by!(user_id:)
  end

  memoize
  def representation_changed?
    representation.previous_changes.present?
  end
end
