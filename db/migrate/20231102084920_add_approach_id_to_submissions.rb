class AddApproachIdToSubmissions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_reference :submissions, :exercise_approach, null: true, foreign_key: true, if_not_exists: true
  end
end
