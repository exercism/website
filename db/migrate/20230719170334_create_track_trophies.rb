class CreateTrackTrophies < ActiveRecord::Migration[7.0]
  def change
    create_table :track_trophies do |t|
      t.string :type, null: false
      t.json :valid_track_slugs, null: true
      t.timestamps

      t.index :type, unique: true
    end
  end
end
