class Bootcamp::UserProject::UpdateStatus
  include Mandate

  initialize_with :user_project

  def call
    user_project.update!(status:)
  end

  def status
    return :available if user_project.solutions.any?(&:in_progress?)

    num_unlocked_exercises = user_project.unlocked_exercises.count
    num_solutions = user_project.solutions.count

    # If there are no unlocked exercises, the project is locked
    return :locked if num_unlocked_exercises.zero?

    # If all solutions have an exercise and they're all complete, the project is complete
    return :completed if num_solutions == num_unlocked_exercises &&
                         user_project.solutions.all?(&:completed?)

    # If we have more exercises than solutions, then there's a new solution
    # that can be created if the user wants to.
    return :available if num_unlocked_exercises > num_solutions

    :locked
  end
end
