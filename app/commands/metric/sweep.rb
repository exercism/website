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

  BATCH_SIZE = 5_000

  def call
    # delete_all deliberately skips callbacks. Metric only has a before_create
    # (setting uniqueness_key/params), so there is nothing to run on destroy.
    #
    # NOTE: There is no index leading with occurred_at (the indexes are
    # track_id, (type, track_id, occurred_at), uniqueness_key and user_id),
    # so this delete is a full table scan. That's fine *because* this job
    # keeps the table permanently small - but if this sweep ever stops
    # running, the table will grow unbounded and this query will degrade
    # into scanning a very large table.
    Metric.where(occurred_at: ...RETENTION_PERIOD.ago).in_batches(of: BATCH_SIZE).delete_all
  end
end
