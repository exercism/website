class DropMetricPeriodTables < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    drop_table :metric_period_minutes
    drop_table :metric_period_days
    drop_table :metric_period_months
  end
end
