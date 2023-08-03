class CreateUserTrackViewedCommunitySolutions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :user_track_viewed_community_solutions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
      t.references :solution, null: false, foreign_key: true

      t.index %i[user_id track_id solution_id], unique: true, name: "index_user_track_viewed_community_solutions_uniq"

      t.timestamps
    end
  end
end
