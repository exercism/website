class ChangeCodeToMediumtextInBootcampTables < ActiveRecord::Migration[7.1]
  def change
    change_column :bootcamp_submissions, :code, :text, limit: 16.megabytes - 1, null: false
    change_column :bootcamp_solutions, :code, :text, limit: 16.megabytes - 1, null: false
  end
end
