class CreateSolutionTags < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :solution_tags do |t|
      t.references :solution, null: false, foreign_key: true
      t.references :exercise, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.string :tag, null: false

      t.index %i[solution_id tag], unique: true

      t.timestamps
    end
  end
end
