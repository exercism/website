require 'test_helper'

class Bootcamp::UserProject::UpdateStatusTest < ActiveSupport::TestCase
  test "locked with no exercises" do
    # This is mainly a sanity test for the rest
    project = create :bootcamp_project
    user_project = create(:bootcamp_user_project, project:)

    Bootcamp::UserProject::UpdateStatus.(user_project)
    assert_equal :locked, user_project.status
  end

  test "available with an exercise with no solution" do
    # This is mainly a sanity test for the rest
    project = create :bootcamp_project
    create(:bootcamp_exercise, project:)
    user_project = create(:bootcamp_user_project, project:)

    Bootcamp::UserProject::UpdateStatus.(user_project)
    assert_equal :available, user_project.status
  end

  test "available if there's an in progress solution" do
    user = create :user, :with_bootcamp_data
    project = create :bootcamp_project
    exercise = create(:bootcamp_exercise, project:)
    create(:bootcamp_solution, exercise:, user:)

    user_project = create(:bootcamp_user_project, user:, project:)
    Bootcamp::UserProject::UpdateStatus.(user_project)
    assert_equal :available, user_project.status
  end

  test "completed if all exercises have completed solutions" do
    user = create :user, :with_bootcamp_data
    project = create :bootcamp_project
    exercise = create(:bootcamp_exercise, project:)
    create :bootcamp_solution, exercise:, user:, completed_at: Time.current

    user_project = create(:bootcamp_user_project, user:, project:)
    Bootcamp::UserProject::UpdateStatus.(user_project)
    assert_equal :completed, user_project.status
  end
end
