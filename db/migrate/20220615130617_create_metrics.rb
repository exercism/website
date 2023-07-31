class CreateMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :metrics do |t|
      t.string :type, null: false
      t.text :params, null: false
      t.belongs_to :track, null: true
      t.belongs_to :user, null: true
      t.string :uniqueness_key, null: false
      t.datetime :occurred_at, null: false

      t.timestamps

      t.index %i[type track_id occurred_at]
      t.index :uniqueness_key, unique: true
    end

    %i[month day].each do |period|
      create_table "metric_period_#{period}s".to_sym do |t|
        t.column period, :tinyint, null: false, default: 0
        t.string :metric_type, null: false
        t.belongs_to :track, null: true
        t.integer :count, null: false

        t.timestamps

        t.index [:metric_type, :track_id, period], unique: true, name: 'uniq'
      end
    end

    create_table :metric_period_minutes do |t|
        t.integer :minute, limit: 2, null: false, default: 0
        t.string :metric_type, null: false
        t.belongs_to :track, null: true
        t.integer :count, null: false

        t.timestamps

        t.index %i[metric_type track_id minute], unique: true, name: 'uniq'
      end
  end
end
