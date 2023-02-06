class AddEmbedUrlToCommunityVideos < ActiveRecord::Migration[7.0]
  def change
    add_column :community_videos, :embed_url, :string, null: false, if_not_exists: true

    unless Rails.env.production?
      CommunityVideo.where(platform: :youtube).find_each do |video|
        video.update(embed_url: "https://www.youtube.com/embed/#{video.embed_id}")
      end
    end
  end
end
