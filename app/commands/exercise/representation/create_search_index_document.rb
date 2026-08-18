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
    # Done as separate queries rather than one join. As a single query MySQL
    # walks the candidates newest-first, doing random lookups into submissions
    # and submission_analyses for each until it finds a match. Analysed
    # submissions are almost all old - for one hot digest the newest analysed
    # representation sat at position 22,367 of 25,113 - so it does nearly the
    # full set of random lookups every time, taking ~17s to return one row.
    #
    # Fetching the candidates first (index-only on index_ex_rep) and then
    # resolving them in bulk lets MySQL batch those lookups instead.
    candidates = representation.
      submission_representations.
      from("submission_representations FORCE INDEX (index_ex_rep)").
      order(id: :desc).
      pluck(:id, :submission_id)
    return nil if candidates.empty?

    analyzed_submission_ids = Submission.
      joins(:analysis).
      where(id: candidates.map(&:second), analysis_status: :completed).
      pluck(:id).
      to_set

    id, = candidates.find { |_, submission_id| analyzed_submission_ids.include?(submission_id) }
    id ? Submission::Representation.find(id) : nil
  end

  attr_reader :solution, :published_iteration

  delegate :track, to: :exercise
  delegate :exercise, :source_submission,
    :oldest_solution, :prestigious_solution,
    to: :representation
  delegate :num_loc, to: :oldest_solution
end
