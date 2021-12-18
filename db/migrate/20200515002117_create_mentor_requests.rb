class CreateMentorRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :mentor_requests do |t|
      t.string :uuid, null: false

      t.belongs_to :solution, foreign_key: true, null: false
      t.belongs_to :track, null: false
      t.belongs_to :exercise, null: false
      t.belongs_to :student, null: false

      t.integer :status, null: false, limit: 1, default: 0

      t.text :comment_markdown, null: false
      t.text :comment_html, null: false

      t.timestamps

      t.index [:status, :track_id]
      t.index [:track_id, :status]
      t.index [:status, :exercise_id]
      t.index [:exercise_id, :status]
    end
  end
end
