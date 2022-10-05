class AddUnlockedHelpTabsToSolutions < ActiveRecord::Migration[7.0]
  def change
    add_column :solutions, :unlocked_help, :boolean, null: false, default: false

    unless Rails.env.production?
      Submission.includes(:solution).find_each do |submission|
        submission.solution.update(unlocked_help: true)
      end
    end
  end
end
