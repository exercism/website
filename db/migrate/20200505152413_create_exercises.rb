class CreateExercises < ActiveRecord::Migration[6.0]
  def change
    create_table :exercises do |t|
      t.belongs_to :track, foreign_key: true, null: false

      t.string :uuid, null: false
      t.string :type, null: false

      t.string :slug, null: false
      t.json :prerequisites, null: false
      t.json :concepts_taught, null: true

      t.timestamps
    end
  end
end
