class AddUniqueKeyToCommunityVideos < ActiveRecord::Migration[7.0]
  def change
    add_index :community_videos, %i[watch_id exercise_id], unique: true, if_not_exists: true
  end
end
