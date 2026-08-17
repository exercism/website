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
  # This *must* stay rank-then-fetch: rank on user_ids only, then fetch the
  # single winning solution. Ranking is served entirely from indexes - the
  # subquery by index_solutions_er_lookup, the ordering by
  # index_user_tracks_track_reputation_user - and never touches a solutions
  # or user_tracks row. That matters a lot: user_tracks rows average ~28KB
  # (86GB across 3.09M rows, thanks to the summary_data/objectives blobs),
  # so any plan that fetches them pays ~0.75ms per row cold.
  #
  # Selecting solution columns during the ranking is similarly fatal: it
  # turns a 36ms covering index read of 64,077 rows into 58,728 random row
  # fetches. Measured on representation 942044 (track 16, 64,077 published
  # solvers), the naive `SELECT solutions.* ... LEFT JOIN user_tracks
  # ORDER BY COALESCE(reputation, 0)` took 108,000ms against this shape's
  # 81ms.
  #
  # The FORCE INDEX is load-bearing too. Left to itself the optimiser
  # flattens the IN into a LooseScan semijoin driven from solutions, then
  # does an eq_ref into user_tracks *per solver* via
  # index_user_tracks_on_track_id_and_user_id, which is not covering. On
  # representation 77 (track 48, 43,275 published solvers) that was 42,387
  # single-row lookups at 0.514ms each - 21.8s of a 22.08s query, with a
  # filesort over 41,073 rows on top because the semijoin plan has no early
  # exit. Forcing the ranking index restores materialise-then-reverse-scan,
  # which stops at the first match: 22.08s -> 0.09s.
  def prestigious_solution
    user_id = UserTrack.
      from('user_tracks FORCE INDEX (index_user_tracks_track_reputation_user)').
      where(track_id: exercise.track_id).
      # This condition is load-bearing for *performance*, not just for the
      # oldest_solution fallback below. Without it the optimiser abandons
      # index_user_tracks_track_reputation_user and the query goes from
      # 81ms to 2,432ms. Do not remove it as redundant.
      where('user_tracks.reputation > 0').
      where(user_id: representation.published_solutions.select(:user_id)).
      order(reputation: :desc).
      pick(:user_id)

    return oldest_solution unless user_id

    representation.published_solutions.find_by!(user_id:)
  end

  memoize
  def representation_changed?
    representation.previous_changes.present?
  end
end
