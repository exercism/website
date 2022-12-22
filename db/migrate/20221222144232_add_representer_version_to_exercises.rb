class AddRepresenterVersionToExercises < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :exercises, :representer_version, :smallint, null: false, default: 1
    end
  end
end
