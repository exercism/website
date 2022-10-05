class AddChannelUrlToCommunityVideos < ActiveRecord::Migration[7.0]
  def change
    add_column :community_videos, :channel_url, :string, null: false, if_not_exists: true
  end
end
