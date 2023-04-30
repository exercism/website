class UsePreciousOnUserTracksLastTouchedAt < ActiveRecord::Migration[7.0]
  def change
    change_column :user_tracks, :last_touched_at, :datetime, precision: 6, null: false
  end
end
