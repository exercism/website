class AddIntroVideoUrlToTracks < ActiveRecord::Migration[7.0]
  def change
    add_column :tracks, :intro_video_youtube_slug, :string, null: true
  end
end
