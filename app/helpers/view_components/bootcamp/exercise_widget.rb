module ViewComponents
  class Bootcamp::ExerciseWidget < ViewComponent
    initialize_with :exercise, solution: nil, user_project: nil, size: nil

    def to_s
      render template: "components/bootcamp/exercise_widget", locals: {
        exercise:,
        project: exercise.project,
        solution:,
        status:,
        size:
      }
    end

    private
    def status
      s = user_project&.exercise_status(exercise, solution) ||
          (::Bootcamp::Exercise::AvailableForUser.(exercise, current_user) ? :available : :locked)

      s = 'completed-bonus' if s == :completed && (solution.passed_bonus_tests? || !exercise.has_bonus_tasks?)
      s
    end

    memoize
    def solution
      @solution || current_user.bootcamp_solutions.find_by(exercise:)
    end

    memoize
    def user_project
      @user_project || ::Bootcamp::UserProject.for(current_user, exercise.project)
    end
  end
end
