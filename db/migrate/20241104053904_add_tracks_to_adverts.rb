class AddTracksToAdverts < ActiveRecord::Migration[7.0]
  def change
    add_column :partner_adverts, :track_slugs, :text, null: true
  end
end
