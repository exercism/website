class CreateCohorts < ActiveRecord::Migration[7.0]
  def change
    create_table :cohorts do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.column :capacity, :int, null: false, default: 0
      t.datetime :begins_at, null: false
      t.datetime :ends_at, null: false
      t.belongs_to :track, null: false, foreign_key: true

      t.timestamps

      t.index :slug, unique: true
    end
  end
end
