class CreateSolutions < ActiveRecord::Migration[6.0]
  def change
    create_table :solutions do |t|
      t.string :type, null: false

      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :exercise, foreign_key: true, null: false

      t.string :uuid, null: false, unique: true
      t.string :public_uuid, null: false, unique: true
      t.string :mentor_uuid, null: false, unique: true
      t.integer :status, null: false, default: 0

      t.string :git_slug, null: false
      t.string :git_sha, null: false

      t.timestamps

      t.index %i[user_id exercise_id], unique: true
    end
  end
end
