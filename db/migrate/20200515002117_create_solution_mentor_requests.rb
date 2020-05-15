class CreateSolutionMentorRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :solution_mentor_requests do |t|
      t.belongs_to :solution, foreign_key: true, null: false

      t.integer :status, null: false, limit: 1, default: 0
      t.integer :type, null: false, limit: 1

      t.text :comment, null: true
      t.integer :bounty, null: false, limit: 2

      t.timestamps
    end
  end
end
