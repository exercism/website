class AddYoutubeIdToBootcampLevels < ActiveRecord::Migration[7.0]
  def change
    add_column :bootcamp_levels, :youtube_id, :string, null: true
  end
end
