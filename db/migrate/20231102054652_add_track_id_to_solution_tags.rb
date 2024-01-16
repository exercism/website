class AddTrackIdToSolutionTags < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :solution_tags, :track_id, :bigint, null: true
    Solution::Tag.joins(:exercise).update_all(track_id: 'exercises.track_id')
    change_column_null :solution_tags, :track_id, false
  end
end
