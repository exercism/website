class CreateUserTrackAcquiredTrophies < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :user_track_acquired_trophies do |t|
      t.string :uuid, null: false
      t.bigint :user_id, null: false
      t.bigint :track_id, null: false
      t.bigint :trophy_id, null: false
      t.boolean :revealed, default: false, null: false

      t.timestamps

      t.index :trophy_id
      t.index %i[user_id trophy_id track_id], unique: true, name: "index_user_track_acquired_trophies_uniq_guard"
      t.index :user_id
      t.index :uuid, unique: true
    end
  end
end
