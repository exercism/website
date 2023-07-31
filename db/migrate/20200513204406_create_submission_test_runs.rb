class CreateSubmissionTestRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :submission_test_runs do |t|
      t.string :uuid, null: false, index: { unique: true }

      t.belongs_to :submission, foreign_key: true, null: false
      t.string :tooling_job_id, null: false

      t.string :status, null: false
      t.text :message, null: true

      t.integer :ops_status, limit: 2, null: false

      t.text :raw_results, null: false

      t.column :version, :tinyint, default: 0, null: false
      t.text :output

      t.timestamps
    end
  end
end
