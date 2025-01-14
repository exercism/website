class Bootcamp::Solution::Create
  include Mandate

  initialize_with :user, :exercise

  def call
    return existing_solution if existing_solution

    guard!

    begin
      Bootcamp::Solution.create!(
        user:,
        exercise:,
        code:
      )
    rescue ActiveRecord::RecordNotUnique
      Bootcamp::Solution.find_by!(
        user:,
        exercise:
      )
    end
  end

  private
  def existing_solution
    Bootcamp::Solution.find_by(user:, exercise:)
  end

  def guard!
    raise ExerciseLockedError unless Bootcamp::Exercise::AvailableForUser.(exercise, user)
  end

  def code
    exercise.stub.gsub(Regexp.new("{{EXERCISE_([-a-z0-9]+)}}")) do
      previous_solutions[::Regexp.last_match(1)].code
    end
  end

  # This is used for the code interpolation, only if actually required.
  memoize
  def previous_solutions
    user_project.solutions.index_by { |s| s.exercise.slug }
  end

  memoize
  def user_project
    Bootcamp::UserProject.find_by!(user:, project: exercise.project)
  rescue StandardError
    Bootcamp::UserProject::Create.(user, exercise.project)
  end
end
