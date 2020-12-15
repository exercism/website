class CreateBugReports < ActiveRecord::Migration[6.1]
  def change
    create_table :bug_reports do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
