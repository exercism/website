class AddTagsToSubmissionAnalyses < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :submission_analyses, :tags_data, :text, null: true
  end
end
