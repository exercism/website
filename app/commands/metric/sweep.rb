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

    # A single primary-key range delete. We already know the id to delete
    # before, so there is nothing left to look up: no row is read in order to
    # evaluate a predicate. (Filtering on occurred_at directly would: there is
    # no index leading with it, which is the whole reason we find the boundary
    # by id.)
    #
    # delete_all deliberately skips callbacks. Metric only has a before_create
    # (setting uniqueness_key/params), so there is nothing to run on destroy.
    Metric.where(id: ...boundary_id).delete_all
  end

  private
  # Walk forwards through the primary key in steps of STEP until we reach a
  # row inside the retention window, and return the id of the last row we saw
  # that was definitively outside it.
  #
  # This costs ~13 primary-key seeks in steady state, and stays proportional
  # to backlog/STEP rather than to the size of the backlog itself.
  #
  # This sweeps by insertion order, not by occurred_at, and those are not the
  # same thing: the GitHub metrics pass the PR/issue's own timestamp and
  # :sign_up passes user.created_at, so a webhook for an old PR inserts a high
  # id with a months-old occurred_at. Production currently holds rows a month
  # older than RETENTION_PERIOD for exactly this reason.
  #
  # That is fine. Those rows age out on insertion order like everything else,
  # a few days late. Read the retention as "7 days of inserts", and don't
  # expect MIN(occurred_at) to sit on the cutoff.
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
