class AddBlurbToExercises < ActiveRecord::Migration[6.1]
  def change
    add_column :exercises, :blurb, :string, null: true, limit: 350, after: :title

    Exercise.update_all(blurb: 'Temporary blurb')

    change_column_null :exercises, :blurb, false
  end
end
