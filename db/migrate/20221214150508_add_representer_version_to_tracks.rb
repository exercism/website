class AddRepresenterVersionToTracks < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :tracks, :representer_version, :smallint, null: true

      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        Track.where(has_representer: true).update_all(representer_version: 1)
      end
    end
  end
end
