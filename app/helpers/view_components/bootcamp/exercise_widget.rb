module ViewComponents
  class Bootcamp::ExerciseWidget < ViewComponent
    initialize_with :exercise, solution: nil, user_project: nil

    def to_s
      render template: "components/bootcamp/exercise_widget", locals: {
        exercise:,
        project: exercise.project,
        solution:,
        status:
      }
    end

    private
    def status
      user_project.exercise_status(exercise, solution)
    end

    memoize
    def solution
      @solution || current_user.solutions.find_by(exercise:)
    end

    memoize
    def user_project
      @user_project || UserProject.for!(current_user, exercise.project)
    end
  end
end
