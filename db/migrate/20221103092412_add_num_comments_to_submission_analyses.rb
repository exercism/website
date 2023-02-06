class AddNumCommentsToSubmissionAnalyses < ActiveRecord::Migration[7.0]
  def change
    execute "ALTER TABLE submission_analyses ADD COLUMN num_comments TINYINT DEFAULT 0 NOT NULL, ALGORITHM=INPLACE, LOCK=NONE"

    unless Rails.env.production?
      Submission::Analysis.find_each do |analysis|
        analysis.update(num_comments: analysis.send(:comment_blocks).size)
      end
    end
  end
end
