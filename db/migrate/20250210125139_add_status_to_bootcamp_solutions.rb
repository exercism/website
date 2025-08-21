class AddStatusToBootcampSolutions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    
    add_column :bootcamp_solutions, :passed_basic_tests, :boolean, default: false
    add_column :bootcamp_solutions, :passed_bonus_tests, :boolean, default: false

    add_index :bootcamp_solutions, :passed_basic_tests
    add_index :bootcamp_solutions, :passed_bonus_tests

    Bootcamp::Solution.completed.update_all(passed_basic_tests: true)
  end
end
