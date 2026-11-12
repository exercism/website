# Works out how far a user has got on Exercism, for PostHog. These go on
# site_visited as person properties, and on checkout_succeeded as event
# properties, which keep a fixed record of what someone had done when they
# paid.
class Analytics::DetermineActivityProperties
  include Mandate

  initialize_with :user

  HELLO_WORLD_SLUG = "hello-world".freeze

  def call
    {
      exercises_completed: completed_solutions.count,
      completed_hello_world: completed_solutions.joins(:exercise).exists?(exercises: { slug: HELLO_WORLD_SLUG }),
      completed_non_hello_world: completed_solutions.joins(:exercise).where.not(exercises: { slug: HELLO_WORLD_SLUG }).exists?,
      mentoring_sessions: user.solution_mentor_discussions.count
    }
  end

  private
  def completed_solutions = user.solutions.completed
end
