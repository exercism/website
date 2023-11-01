class CreateExerciseApproachTags < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :exercise_approach_tags do |t|
      t.belongs_to :exercise_approach, null: false
      t.integer :condition_type, null: false, default: 0
      t.string :tag, null: false

      t.index %i[exercise_approach_id tag], unique: true
      t.index %i[exercise_approach_id tag condition_type], unique: false, name: "index_exercise_approach_tags_approach_tag_condition_type"

      t.timestamps
    end
  end
end
