class CreateSubmissionAnalyses < ActiveRecord::Migration[6.0]
  def change
    create_table :submission_analyses do |t|
      t.belongs_to :submission, foreign_key: true, null: false

      t.integer :ops_status, limit: 2, null: false

      t.json :data, null: true

      t.string :tooling_job_id, null: false

      t.timestamps
    end
  end
end
