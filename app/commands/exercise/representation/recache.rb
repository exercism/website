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

  # Picks the published solver with the highest reputation on this track,
  # falling back to the oldest solution when nobody has any.
  #
  # This reads the denormalised user_tracks.reputation column instead of
  # aggregating the whole reputation history of every published solver.
  # The LEFT JOIN keeps every published solver in the candidate set: anyone
  # without a user_tracks row simply scores 0, exactly as they would if they
  # had no reputation tokens for the track.
  def prestigious_solution
    representation.published_solutions.
      joins(<<~SQL.squish).
        LEFT JOIN user_tracks
          ON user_tracks.user_id = solutions.user_id
          AND user_tracks.track_id = #{exercise.track_id.to_i}
      SQL
      where('COALESCE(user_tracks.reputation, 0) > 0').
      order(Arel.sql('COALESCE(user_tracks.reputation, 0) DESC'), :id).
      first || oldest_solution
  end

  memoize
  def representation_changed?
    representation.previous_changes.present?
  end
end
