class AddToolingStatusColumnsToTracks < ActiveRecord::Migration[7.0]
  def change
    add_column :tracks, :has_representer, :boolean, null: false, default: false
    add_column :tracks, :has_analyzer, :boolean, null: false, default: false
  end
end
