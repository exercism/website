class CreateCohorts < ActiveRecord::Migration[7.0]
  def change
    create_table :cohorts do |t|
      t.belongs_to :track, null: false, foreign_key: true

      t.string :slug, null: false, index: { unique: true }
      t.string :name, null: false
      t.column :capacity, :int, null: false, default: 0
      t.datetime :begins_at, null: false
      t.datetime :ends_at, null: false

      t.timestamps
    end
  end
end
