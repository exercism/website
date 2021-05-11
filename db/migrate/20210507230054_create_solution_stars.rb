class CreateSolutionStars < ActiveRecord::Migration[6.1]
  def change
    create_table :solution_stars, if_not_exists: true do |t|
      t.belongs_to :solution, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
