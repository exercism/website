class AddSummaryDataToUserTrack < ActiveRecord::Migration[6.1]
  def change
    add_column :user_tracks, :summary_data, :json, null: false
    add_column :user_tracks, :summary_key, :string, null: true
  end
end
