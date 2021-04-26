class RenameBugReports < ActiveRecord::Migration[6.1]
  def change
    rename_table :bug_reports, :problem_reports
    add_column :problem_reports, :type, :tinyint, null: false, default: 0
    add_belongs_to :problem_reports, :track, null: true
    add_belongs_to :problem_reports, :exercise, null: true

    add_belongs_to :problem_reports, :about, polymorphic: true, null: true
  end
end
