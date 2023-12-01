class TrainingData::CodeTagsSample::CreateTrainingData
  include Mandate

  initialize_with :track

  def call
    @solutions = []

    find_solutions(PREFERENTIAL_EXERCISE_SLUGS.dup)
    find_solutions(non_preferential_exercise_slugs)

    create_data!
  end

  private
  attr_reader :solutions

  def create_data!
    solutions.each do |solution|
      TrainingData::CodeTagsSample::Create.(solution)
    end
  end

  memoize
  def exercises
    track.practice_exercises.each_with_object({}) do |exercise, exercises|
      num_published_solutions = exercise.representations.distinct.pluck(:num_published_solutions).sort
      exercises[exercise.slug] = { exercise:, num_published_solutions: }
    end
  end

  def find_solutions(exercise_slugs)
    while solutions.size < MAX_NUM_SOLUTIONS && exercise_slugs.present?
      exercise_slug = exercise_slugs.shift

      next unless exercises.key?(exercise_slug)

      num_published_solutions = exercises[exercise_slug][:num_published_solutions].pop
      next if num_published_solutions.nil?

      # Only continue searching this exercise when there is at least
      # one num_published_solutions value we haven't checked
      exercise_slugs << exercise_slug if exercises[exercise_slug][:num_published_solutions].present?

      exercise = exercises[exercise_slug][:exercise]
      solution = find_solution(exercise, num_published_solutions)

      next if solution.nil?

      solutions << solution

      # We've found a solution for this num_published_solutions value,
      # so we can retry next time to see if there are more
      exercises[exercise_slug][:num_published_solutions] << num_published_solutions
    end
  end

  def find_solution(exercise, num_published_solutions)
    exercise_solution_filepaths = exercise.git.solution_filepaths

    Solution.published.
      where.not(id: TrainingData::CodeTagsSample.select(:solution_id)).
      where.not(id: solutions.map(&:id)).
      where(id: exercise.representations.where(num_published_solutions:).select(:prestigious_solution_id)).
      where(published_iteration_head_tests_status: :passed).
      order(num_loc: :asc).
      limit(10).
      find do |solution|
        submission = solution.latest_published_iteration_submission
        next if submission.nil?

        solution_files = submission.files.select do |file|
          next unless exercise_solution_filepaths.include?(file.filename)
          next unless file.content.present?

          true
        end

        solution_files.size == exercise_solution_filepaths.size
      end
  end

  memoize
  def non_preferential_exercise_slugs
    track.practice_exercises.
      where.not(slug: PREFERENTIAL_EXERCISE_SLUGS).
      order(:slug).
      pluck(:slug)
  end

  MAX_NUM_SOLUTIONS = 20
  PREFERENTIAL_EXERCISE_SLUGS = %w[
    acronym
    collatz-conjecture
    difference-of-squares
    hamming
    raindrops
    resistor-color
    rna-transcription
    series
    two-fer
    word-count
  ].freeze
  private_constant :MAX_NUM_SOLUTIONS, :PREFERENTIAL_EXERCISE_SLUGS
end
