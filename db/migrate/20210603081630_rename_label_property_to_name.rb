class RenameLabelPropertyToName < ActiveRecord::Migration[6.1]
  def change
    rename_column :github_issue_labels, :label, :name
  end
end
