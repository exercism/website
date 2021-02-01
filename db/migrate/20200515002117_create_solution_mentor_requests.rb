class CreateSolutionMentorRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :solution_mentor_requests do |t|
      t.string :uuid, null: false

      t.belongs_to :solution, foreign_key: true, null: false

      t.integer :status, null: false, limit: 1, default: 0
      t.integer :type, null: false, limit: 1

      t.text :comment, null: true

      t.belongs_to :locked_by, foreign_key: { to_table: :users }, null: true
      t.datetime :locked_until, null: true

      t.timestamps
    end
  end
end
