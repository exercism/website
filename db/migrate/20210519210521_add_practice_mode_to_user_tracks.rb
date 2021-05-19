class AddPracticeModeToUserTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :user_tracks, :practice_mode, :boolean, null: false, default: false
  end
end
