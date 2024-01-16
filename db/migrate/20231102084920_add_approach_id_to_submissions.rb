class AddApproachIdToSubmissions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_reference :submissions, :approach, null: true, foreign_key: { to_table: :exercise_approaches }, if_not_exists: true
  end
end
