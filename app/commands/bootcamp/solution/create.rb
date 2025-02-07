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
    exercise.stub.gsub(Regexp.new("{{EXERCISE:([-a-z0-9]+)/([-a-z0-9]+)}}")) do
      project_slug = ::Regexp.last_match(1)
      exercise_slug = ::Regexp.last_match(2)
      user.bootcamp_solutions.joins(exercise: :project).
        where('bootcamp_exercises.slug = ? AND bootcamp_projects.slug = ?', exercise_slug, project_slug).
        first&.code || ""
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
