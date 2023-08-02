class CreateUserTrackViewedCommunitySolutions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :user_track_viewed_community_solutions do |t|
      t.references :user_track, null: false, foreign_key: true
      t.references :solution, null: false, foreign_key: true

      t.timestamps
    end
  end
end
