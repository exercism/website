class CreateBootcampSolutions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :bootcamp_solutions do |t|
      t.belongs_to :user
      t.belongs_to :exercise
      
      t.string :uuid, null: false

      t.text :code, null: false

      t.datetime :completed_at, null: true
      t.timestamps
      
      t.index [:user_id, :exercise_id], unique: true
    end
  end
end
