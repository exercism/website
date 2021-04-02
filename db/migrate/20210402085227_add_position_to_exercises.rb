class AddPositionToExercises < ActiveRecord::Migration[6.1]
  def change
    add_column :exercises, :position, :integer, null: true, after: :blurb

    Exercise.find_each.with_index do |exercise, position|
      exercise.update!(position: position)
    end 

    change_column_null :exercises, :position, false

    add_index :exercises, [:track_id, :position]
  end
end
