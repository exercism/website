class AddLabsYoutubeIdToLevels < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    
    add_column :bootcamp_levels, :labs_youtube_id, :string
  end
end
