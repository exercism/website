class AddIconNameToExercises < ActiveRecord::Migration[6.1]
  def change
    add_column :exercises, :icon_name, :string, null: true
    Exercise.update_all("icon_name = slug")
    change_column_null :exercises, :icon_name, false
  end
end
