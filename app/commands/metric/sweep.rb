class Metric::Sweep
  include Mandate

  # Metrics are effectively write-only. Nothing aggregates them any more -
  # the only readers are "most recent" lookups (the impact map and each
  # track's activity ticker), so we only need to retain a short window.
  #
  # We keep 7 days rather than (say) 1 so that quiet tracks still have at
  # least one row for the activity ticker's `.last` lookup. The extra days
  # cost a trivial amount of disk.
  RETENTION_PERIOD = 7.days

  STEP = 5_000

  def call
    return if boundary_id.nil?

    # The delete is a pure primary-key range, so it stays cheap however large
    # a backlog has accumulated - we never read a row in order to evaluate a
    # predicate. (Filtering on occurred_at directly would: there is no index
    # leading with it, which is the whole reason we find the boundary by id.)
    #
    # delete_all deliberately skips callbacks. Metric only has a before_create
    # (setting uniqueness_key/params), so there is nothing to run on destroy.
    #
    # in_batches is insurance for the catch-up case after the job has not run
    # for a while, rather than for the ~64,000-row steady state.
    Metric.where(id: ...boundary_id).in_batches(of: STEP).delete_all
  end

  private
  # Walk forwards through the primary key in steps of STEP until we reach a
  # row inside the retention window, and return the id of the last row we saw
  # that was definitively outside it.
  #
  # This costs ~13 primary-key seeks in steady state, and stays proportional
  # to backlog/STEP rather than to the size of the backlog itself.
  #
  # This relies on id order matching occurred_at order, which holds because
  # Metric::Create sets occurred_at at insertion time. If anything ever
  # backdated occurred_at, this would behave differently to a timestamp filter.
  memoize
  def boundary_id
    cutoff = RETENTION_PERIOD.ago
    id = Metric.minimum(:id)
    return if id.blank?

    boundary = nil

    loop do
      # We probe with `id >= n ORDER BY id LIMIT 1` rather than `id = n`
      # because ids have gaps (from rolled-back inserts), so an exact-id
      # probe would miss rows. This is still a single primary-key seek.
      probe_id, occurred_at = Metric.where(id: id..).order(:id).limit(1).pick(:id, :occurred_at)
      break if probe_id.nil? || occurred_at >= cutoff

      boundary = probe_id
      id = probe_id + STEP
    end

    # The boundary is deliberately approximate: stopping at the last probe
    # that was definitively older than the cutoff retains up to STEP rows
    # more than strictly necessary (about two hours of data). That is
    # intentional - it removes any need to reason about off-by-one errors
    # against the cutoff.
    boundary
  end
end
