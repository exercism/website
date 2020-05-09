class CreateUserTrackConcepts < ActiveRecord::Migration[6.0]
  def change
    create_table :user_track_concepts do |t|
      t.belongs_to :user_track, null: false
      t.belongs_to :track_concept, null: false

      t.timestamps
    end
  end
end
