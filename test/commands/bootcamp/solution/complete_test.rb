require 'test_helper'

class Bootcamp::Solution::CompleteTest < ActiveSupport::TestCase
  test "completes the solution" do
    freeze_time do
      user = create :user, :with_bootcamp_data
      project = create :bootcamp_project
      create(:bootcamp_user_project, user:, project:)
      exercise = create(:bootcamp_exercise, project:)
      solution = create :bootcamp_solution, exercise:, user:, completed_at: Time.current

      Bootcamp::Solution::Complete.(solution)

      assert_equal Time.current, solution.completed_at
      assert solution.completed?
    end
  end

  test "updates the status of the project" do
    freeze_time do
      user = create :user, :with_bootcamp_data
      project = create :bootcamp_project
      user_project = create(:bootcamp_user_project, user:, project:)
      exercise = create(:bootcamp_exercise, project:)
      solution = create(:bootcamp_solution, exercise:, user:)

      Bootcamp::UserProject::UpdateStatus.expects(:call).with(user_project)
      Bootcamp::Solution::Complete.(solution)
    end
  end
end
