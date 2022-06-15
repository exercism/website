class CreateMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :metrics do |t|
      t.column :action, :tinyint, null: false, default: 0
      t.string :country_code, null: true
      t.belongs_to :track, null: true
      t.belongs_to :user, null: true

      t.timestamps

      t.index :created_at
    end
  end
end
