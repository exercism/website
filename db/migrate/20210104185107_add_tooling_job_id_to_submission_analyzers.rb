class AddToolingJobIdToSubmissionAnalyzers < ActiveRecord::Migration[6.1]
  def change
    add_column :submission_analyses, :tooling_job_id, :string, null: false
  end
end
