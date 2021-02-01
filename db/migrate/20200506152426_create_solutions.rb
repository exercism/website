class CreateSolutions < ActiveRecord::Migration[6.0]
  def change
    create_table :solutions do |t|
      t.string :type, null: false

      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :exercise, foreign_key: true, null: false

      t.string :uuid, null: false, unique: true

      t.string :git_slug, null: false
      t.string :git_sha, null: false

      t.datetime :downloaded_at, null: true
      t.datetime :completed_at, null: true
      t.datetime :published_at, null: true

      t.column :mentoring_status, :tinyint, null: false, default: 0

      t.timestamps

      t.index %i[user_id exercise_id], unique: true
    end
  end
end
