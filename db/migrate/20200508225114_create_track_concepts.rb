class CreateTrackConcepts < ActiveRecord::Migration[6.0]
  def change
    create_table :track_concepts do |t|
      t.belongs_to :track, foreign_key: true, null: false

      t.string :uuid, null: false

      t.string :name, null: false

      t.timestamps
    end
  end
end
