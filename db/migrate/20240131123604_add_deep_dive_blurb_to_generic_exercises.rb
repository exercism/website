class AddDeepDiveBlurbToGenericExercises < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :generic_exercises, :deep_dive_blurb, :string, null: true
  end
end
