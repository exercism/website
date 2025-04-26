class Bootcamp::Solution::GenerateStub
  include Mandate

  initialize_with :exercise, :user, :language

  def call
    exercise.stub(language).gsub(Regexp.new("{{EXERCISE:([-a-z0-9]+)/([-a-z0-9]+)}}")) do
      project_slug = ::Regexp.last_match(1)
      exercise_slug = ::Regexp.last_match(2)
      user.bootcamp_solutions.joins(exercise: :project).
        where('bootcamp_exercises.slug = ? AND bootcamp_projects.slug = ?', exercise_slug, project_slug).
        first&.code || ""
    end
  end
end
