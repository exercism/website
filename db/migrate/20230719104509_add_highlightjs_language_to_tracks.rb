class AddHighlightjsLanguageToTracks < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :tracks, :highlightjs_language, :string, null: true

    Track.find_each do |track|
      track.update(highlightjs_language: track.git.highlightjs_language)
    end
  end
end
