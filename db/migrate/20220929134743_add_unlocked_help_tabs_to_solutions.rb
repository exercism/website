class AddUnlockedHelpTabsToSolutions < ActiveRecord::Migration[7.0]
  def change
    add_column :solutions, :unlocked_help, :boolean, null: false, default: false

    unless Rails.env.production?
      Solution.find_each do |solution|
        solution.update(unlocked_help: solution.iterated?)
      end
    end
  end
end
