class AddYoutubeIdToBootcampLevels < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    
    add_column :bootcamp_levels, :youtube_id, :string, null: true
  end
end
