class AddRepresenterVersionToTracks < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :tracks, :representer_version, :smallint, null: true
    end
  end
end
