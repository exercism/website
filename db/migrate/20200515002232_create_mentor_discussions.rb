class CreateMentorDiscussions < ActiveRecord::Migration[6.0]
  def change
    create_table :mentor_discussions do |t|
      t.string :uuid, null: false

      t.belongs_to :solution, foreign_key: true, null: false
      t.belongs_to :mentor, foreign_key: { to_table: :users }, null: false
      t.belongs_to :request, foreign_key: { to_table: :mentor_requests }, null: true

      t.column :status, :tinyint, null: false, default: 0

      t.datetime :awaiting_student_since, null: true
      t.datetime :awaiting_mentor_since, null: true

      t.datetime :mentor_finished_at, null: true
      t.datetime :student_finished_at, null: true

      t.timestamps
    end
  end
end
