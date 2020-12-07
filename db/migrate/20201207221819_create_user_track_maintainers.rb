class CreateUserTrackMaintainers < ActiveRecord::Migration[6.1]
  def change
    create_table :user_track_maintainers do |t|
      t.belongs_to :user
      t.belongs_to :track

      t.boolean :alumnus, null: false, default: false
      t.boolean :visible, null: false, default: true

      t.timestamps
    end
  end
end
