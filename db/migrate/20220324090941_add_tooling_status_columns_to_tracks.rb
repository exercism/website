class AddToolingStatusColumnsToTracks < ActiveRecord::Migration[7.0]
  def change
    add_column :tracks, :has_representer, :boolean, null: false, default: false
    add_column :tracks, :has_analyzer, :boolean, null: false, default: false

    Track.find_each do |track|
      track.update(
         has_representer: track.git.has_representer?,
         has_analyzer: track.git.has_analyzer?,
      )
    end
  end
end
