class CreateMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :metrics do |t|
      t.column :metric_action, :tinyint, null: false, default: 0
      t.string :country_code, null: true
      t.belongs_to :track, null: true
      t.belongs_to :user, null: true

      t.timestamps

      t.index :created_at
    end

    %i[month day hour].each do |period|
      create_table "metric_period_#{period}s".to_sym do |t|
        t.column period, :tinyint, null: false, default: 0
        t.column :metric_action, :tinyint, null: false, default: 0
        t.belongs_to :track, null: true
        t.integer :count, null: false

        t.timestamps

        t.index :created_at
      end
    end
  end
end
