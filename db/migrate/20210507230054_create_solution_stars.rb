class CreateSolutionStars < ActiveRecord::Migration[7.0]
  def change
    create_table :solution_stars, if_not_exists: true do |t|
      t.belongs_to :solution, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.index [:solution_id, :user_id], unique: true

      t.timestamps
    end
  end
end
