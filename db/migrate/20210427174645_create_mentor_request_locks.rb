class CreateMentorRequestLocks < ActiveRecord::Migration[7.0]
  def change
    create_table :mentor_request_locks do |t|
      t.belongs_to :request, foreign_key: {to_table: :mentor_requests}, null: false
      t.bigint :locked_by_id, null: false
      t.datetime :locked_until, null: false

      t.index [:request_id, :locked_by_id]
    end
  end
end
