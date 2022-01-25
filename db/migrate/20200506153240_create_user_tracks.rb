class CreateUserTracks < ActiveRecord::Migration[7.0]
  def change
    create_table :user_tracks do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :track, foreign_key: true, null: false

      t.text :summary_data, null: false
      t.string :summary_key, null: true

      t.boolean :practice_mode, null: false, default: false
      t.boolean :anonymous_during_mentoring, null: false, default: false
      t.datetime :last_touched_at, null: false

      t.text :objectives

      t.index %i[user_id track_id], unique: true

      t.timestamps
    end
  end
end
