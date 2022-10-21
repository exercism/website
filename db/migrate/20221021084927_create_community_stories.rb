class CreateCommunityStories < ActiveRecord::Migration[7.0]
  def change
    create_table :community_stories do |t|
      t.belongs_to :interviewer, null: false, foreign_key: {to_table: :users}
      t.belongs_to :interviewee, null: false, foreign_key: {to_table: :users}

      t.string :uuid, null: false, index: {unique: true}
      t.string :slug, null: false
      t.string :title, null: false
      t.string :blurb, null: false, limit: 280
      t.string :thumbnail_url, null: false
      t.string :image_url, null: false
      t.string :youtube_id, null: false
      t.integer :length_in_minutes, limit: 2, null: false
      t.datetime :published_at, null: false

      t.timestamps
    end
  end
end
