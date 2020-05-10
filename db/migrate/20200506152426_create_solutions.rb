class CreateSolutions < ActiveRecord::Migration[6.0]
  def change
    create_table :solutions do |t|
      t.string :type, null: false

      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :exercise, foreign_key: true, null: false

      t.string :uuid, null: false, unique: true

      t.timestamps

      t.index [:user_id, :exercise_id], unique: true
    end
  end
end
