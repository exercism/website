class RemoveUnusedMetricsIndexes < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    # performance_schema.table_io_waits_summary_by_index_usage on the writer
    # showed zero fetches against all three of these, while
    # index_metrics_on_track_id took 9.4m and
    # index_metrics_on_type_and_track_id_and_occurred_at took 200k.
    #
    # Nothing queries metrics by user_id: there is no has_many :metrics, no
    # foreign key, and the only reads are the activity ticker (track_id + type)
    # and the impact map (type). belongs_to :user still writes the column.
    remove_index :metrics, :user_id,
      name: "index_metrics_on_user_id",
      if_exists: true

    # These two only ever existed on production - no migration creates them and
    # they are absent from schema.rb. They are the same three columns in two
    # different orders, so they look like a column-ordering experiment that was
    # never cleaned up. if_exists because they are not present anywhere else.
    remove_index :metrics, %i[occurred_at track_id type],
      name: "index_metrics_on_occurred_at_and_track_id_and_type",
      if_exists: true
    remove_index :metrics, %i[occurred_at type track_id],
      name: "index_metrics_on_occurred_at_and_type_and_track_id",
      if_exists: true
  end
end
