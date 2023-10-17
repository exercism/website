class CreateExerciseTags < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :exercise_tags do |t|
      t.string :tag, null: false
      t.boolean :filterable, null: false, default: true

      t.references :exercise, null: false, foreign_key: true

      t.timestamps
    end
  end
end
