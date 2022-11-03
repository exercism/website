class AddNumCommentsToSubmissionAnalyses < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_analyses, :num_comments, :integer, limit: 1, default: 0, null: false

    unless Rails.env.production?
      Submission::Analysis.find_each do |analysis|
        analysis.update(num_comments: analysis.comments.size)
      end
    end
  end
end
