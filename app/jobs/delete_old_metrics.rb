class DeleteOldMetrics < ApplicationJob
  queue_as :metrics

  def perform
    loop do
      # Don't just destroy via the metrics, else we'll lock the table.
      # It's better to get the ids then destroy by primary key
      ids = Metric.where("occurred_at < ?", Time.current - 3.months).limit(100).pluck(:id)
      break unless ids.present?

      Metric.where(id: ids).delete_all
    end
  end
end
