class Exercise::Representation::CreateSearchIndexDocument
  include Mandate

  initialize_with :representation do
    # Check a maximum of 5 solutions until we find one that's not broken.
    # This is just an extra guard in case one or two solutions get in a weird state.
    5.times do
      @solution = representation.published_solutions.
        where.not(user_id: User::GHOST_USER_ID).
        first
      @published_iteration = @solution&.latest_published_iteration
      break if @published_iteration
    end
  end

  def call
    raise NoPublishedSolutionForRepresentationError unless solution
    raise NoPublishedSolutionForRepresentationError unless published_iteration
    raise NoPublishedSolutionForRepresentationError unless passes_latest_tests?

    {
      id: representation.id,
      featured_solution_id: solution.id,
      num_loc: solution.num_loc,
      num_solutions: representation.num_published_solutions,
      code: published_iteration.submission.files.map(&:content) || [],
      exercise: {
        id: solution.exercise.id,
        slug: solution.exercise.slug,
        title: solution.exercise.title
      },
      track: {
        id: solution.track.id,
        slug: solution.track.slug,
        title: solution.track.title
      }
    }
  end

  memoize
  def passes_latest_tests?
    # If any of them pass, that's good enough for us.
    return true if representation.published_solutions.
      where(published_iteration_head_tests_status: :passed).
      exists?

    # If we have any that fail, then that's bad so we it doesn't pass the latest tests.
    !representation.published_solutions.
      where(published_iteration_head_tests_status: %i[failed errored]).
      exists?
  end

  attr_reader :solution, :published_iteration
end
