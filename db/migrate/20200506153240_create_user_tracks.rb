class CreateUserTracks < ActiveRecord::Migration[6.0]
  def change
    create_table :user_tracks do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :track, foreign_key: true, null: false
      t.index [:user_id, :track_id], unique: true

      t.timestamps
    end
  end
end
