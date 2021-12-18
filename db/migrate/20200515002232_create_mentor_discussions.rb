class CreateMentorDiscussions < ActiveRecord::Migration[7.0]
  def change
    create_table :mentor_discussions do |t|
      t.string :uuid, null: false

      t.belongs_to :solution, foreign_key: true, null: false
      t.belongs_to :mentor, foreign_key: { to_table: :users }, null: false
      t.belongs_to :request, foreign_key: { to_table: :mentor_requests }, null: false

      t.column :status, :tinyint, null: false, default: 0
      t.column :rating, :tinyint, null: true
      t.integer :num_posts, limit:3, null: false, default: 0
      t.boolean :anonymous_mode, default: false, null: false

      t.datetime :awaiting_student_since, null: true
      t.datetime :awaiting_mentor_since, null: true
      t.datetime :mentor_reminder_sent_at, null: true

      t.datetime :finished_at, null: true
      t.column :finished_by, :tinyint, null: true

      t.timestamps
    end
  end
end
