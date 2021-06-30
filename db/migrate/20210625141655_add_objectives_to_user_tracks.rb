class AddObjectivesToUserTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :user_tracks, :objectives, :text
  end
end
