class Exercise::Representation::CreateSearchIndexDocument
  include Mandate

  initialize_with :representation

  def call
    raise NoPublishedSolutionForRepresentationError unless oldest_solution
    raise NoPublishedSolutionForRepresentationError unless prestigious_solution
    raise NoPublishedSolutionForRepresentationError unless passes_latest_tests?

    {
      id: representation.id,
      oldest_solution_id: representation.oldest_solution_id,
      prestigious_solution_id: representation.prestigious_solution_id,
      num_loc:,
      num_solutions:,
      max_reputation:,
      tags:,
      code:,
      exercise: {
        id: exercise.id,
        slug: exercise.slug,
        title: exercise.title
      },
      track: {
        id: track.id,
        slug: track.slug,
        title: track.title
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

  def code = source_submission.files.map(&:content) || []
  def max_reputation = prestigious_solution.user.reputation_for_track(track).to_i
  def num_solutions = representation.num_published_solutions

  def tags
    return [] if last_analyzed_submission_representation.nil?

    last_analyzed_submission_representation.submission.analysis.tags
  end

  memoize
  def last_analyzed_submission_representation
    representation.
      submission_representations.
      joins(submission: :analysis).
      where(submission: { analysis_status: :completed }).
      last
  end

  attr_reader :solution, :published_iteration

  delegate :track, to: :exercise
  delegate :exercise, :source_submission,
    :oldest_solution, :prestigious_solution,
    to: :representation
  delegate :num_loc, to: :oldest_solution
end
