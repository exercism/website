class IncreaseLimitOnNumPublishedSolutions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    change_column :exercise_representations, :num_published_solutions, :integer, limit: 4, default: 0, null: false
  end
end
