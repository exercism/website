class CreateSubmissionRepresentations < ActiveRecord::Migration[7.0]
  def change
    create_table :submission_representations do |t|
      t.belongs_to :submission, foreign_key: true, null: false
      t.string :tooling_job_id, null: false

      t.integer :ops_status, limit: 2, null: false

      t.text :ast, null: true
      t.string :ast_digest, null: true

      t.timestamps
    end
  end
end
