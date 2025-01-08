class CreateBootcampExercises < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :bootcamp_exercises do |t|
      t.belongs_to :project
      t.string :slug, null: false

      t.integer :idx, null: false
      t.string :title, null: false
      t.text :description, null: false
      t.integer :level_idx, null: false

      t.timestamps
      
      t.index [:project_id, :slug], unique: true
      t.index :level_idx
    end
  end
end
