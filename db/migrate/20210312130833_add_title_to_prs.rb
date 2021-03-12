class AddTitleToPrs < ActiveRecord::Migration[6.1]
  def change
    add_column :github_pull_requests, :title, :string, null: true
  end
end
