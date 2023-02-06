class AddHasApproachesToExercises < ActiveRecord::Migration[7.0]
  def change
    add_column :exercises, :has_approaches, :boolean, null: false, default: false

    unless Rails.env.production?
      Exercise.find_each do |exercise|
        Exercise::UpdateHasApproaches.(exercise)
      end
    end
  end
end
