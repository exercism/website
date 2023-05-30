class AddPublishedAtToCommunityVideos < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :community_videos, :published_at, :datetime, precision: nil, null: false, default: -> { 'NOW()' }
    add_index :community_videos, :published_at
    CommunityVideo.update_all('published_at = created_at')
  end
end
