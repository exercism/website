class CreateMentorDiscussions < ActiveRecord::Migration[6.0]
  def change
    create_table :mentor_discussions do |t|
      t.string :uuid, null: false

      t.belongs_to :solution, foreign_key: true, null: false
      t.belongs_to :mentor, foreign_key: { to_table: :users }, null: false
      t.belongs_to :request, foreign_key: { to_table: :mentor_requests }, null: true

      t.datetime :requires_mentor_action_since, null: true
      t.datetime :requires_student_action_since, null: true

      t.datetime :finished_at, null: true

      t.timestamps
    end
  end
end
