class Bootcamp::Solution::Complete
  include Mandate

  initialize_with :solution

  def call
    return if solution.completed?

    # It's essential that both of these lines are called
    # inline to ensure next exercise selection is correct
    solution.update!(completed_at: Time.current)
    Bootcamp::UserProject::UpdateStatus.(user_project)
    Bootcamp::UpdateUserLevel.(user, solution.exercise.level.part)
  end

  private
  def user_project
    Bootcamp::UserProject.for!(user, project)
  rescue ActiveRecord::RecordNotFound
    Bootcamp::UserProject::Create.(user, project)
  end

  delegate :user, :project, to: :solution
end
