class AddStatusToExercises < ActiveRecord::Migration[6.1]
  def change
    add_column :exercises, :status, :tinyint, null: false, default: 0

    remove_column :exercises, :deprecated, :tinyint
  end
end
