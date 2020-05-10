class CreateUserTrackConcepts < ActiveRecord::Migration[6.0]
  def change
    create_table :user_track_concepts do |t|
      t.belongs_to :user_track, foreign_key: true, null: false
      t.belongs_to :track_concept, foreign_key: true, null: false

      t.timestamps
    end
  end
end
