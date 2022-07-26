class AddNumPublishedSolutionsToExercises < ActiveRecord::Migration[7.0]
  def change
    add_column :exercises, :num_published_solutions, :integer, null: false, default: 0

    Exercise.find_each do |exercise|
      exercise.update(num_published_solutions: exercise.solutions.published.count)
    end
  end
end
