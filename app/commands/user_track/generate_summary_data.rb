class UserTrack::GenerateSummaryData
  include Mandate

  initialize_with :track, :user_track

  def call
    t = Time.now.to_f
    Rails.logger.info "[BM] Starting generating user summary"

    generate!.tap do
      Rails.logger.info "[BM] Finished generating user summary"
      Rails.logger.info "[BM] Generating User Summary: #{Time.now.to_f - t}"
    end
  end

  def generate!
    generate_exercises_data!
    calculate_unlocking!
    generate_concepts_data!

    {
      exercises: exercises_hash,
      concepts: concepts_hash
    }.with_indifferent_access
  end

  private
  attr_reader :exercises_data, :concepts_hash

  memoize
  def exercises_hash
    exercises_data.transform_values do |exercise|
      exercise.slice(:id, :slug, :type, :position, :status, :unlocked, :has_solution, :completed_at)
    end
  end

  memoize
  def generate_concepts_data!
    @concepts_hash = track.concepts.each.with_object({}) do |concept, hash|
      concept_exercises_data = exercises_data.select { |_, ex| ex[:type] == :concept }
      concept_exercises = concept_exercises_data.values.
        select { |e| e[:taught_concepts].include?(concept.slug) }.
        map { |e| e[:slug] }

      practice_exercises_data = exercises_data.select { |_, ex| ex[:type] == :practice }
      practice_exercises = practice_exercises_data.values.
        select { |e| e[:practiced_concepts].include?(concept.slug) }.
        map { |e| e[:slug] }

      completed_solutions = solutions_data.values.select { |s| s[:completed_at] }
      num_completed_concept_solutions = completed_solutions.count { |s| concept_exercises.include?(s[:slug]) }
      num_completed_practice_solutions = completed_solutions.count { |s| practice_exercises.include?(s[:slug]) }

      hash[concept.slug] = {
        id: concept.id,
        slug: concept.slug,
        num_concept_exercises: concept_exercises.count,
        num_practice_exercises: practice_exercises.count,
        num_completed_concept_exercises: num_completed_concept_solutions,
        num_completed_practice_exercises: num_completed_practice_solutions,
        unlocked: unlocked_concept_slugs.include?(concept.slug),
        learnt: learnt_concept_slugs.include?(concept.slug)
      }
    end
  end

  # This deliberately plucks rather than instantiating ActiveRecord objects.
  # A large track has 130+ exercises with several hundred rows across the
  # concept join tables, and instantiating all of that costs far more time
  # than the queries themselves - especially as we only want a few scalars
  # off each row.
  def generate_exercises_data!
    exercises = pluck_exercises(user_track.concept_exercises) +
                pluck_exercises(user_track.practice_exercises)

    exercise_ids = exercises.map(&:first)
    prerequisites = concept_slugs_by_exercise_id(Exercise::Prerequisite, exercise_ids)
    practiced = concept_slugs_by_exercise_id(Exercise::PracticedConcept, exercise_ids)
    taught = concept_slugs_by_exercise_id(Exercise::TaughtConcept, exercise_ids)

    @exercises_data = exercises.each_with_object({}) do |(id, slug, type, position), data|
      solution_data = solutions_data[slug]
      concept_exercise = type == ConceptExercise.to_s

      exercise_data = {
        id:,
        slug:,
        type: type.sub("Exercise", "").downcase.to_sym,
        position:,
        tutorial: slug == Exercise::TUTORIAL_SLUG,
        prerequisite_concept_slugs: prerequisites[id],
        practiced_concepts: concept_exercise ? [] : practiced[id],
        has_solution: !!solution_data,
        completed_at: solution_data&.fetch(:completed_at) || nil
      }
      exercise_data[:taught_concepts] = taught[id] if concept_exercise
      data[slug] = exercise_data
    end
  end

  def pluck_exercises(exercises)
    exercises.except(:includes).pluck(:id, :slug, :type, :position)
  end

  def concept_slugs_by_exercise_id(klass, exercise_ids)
    klass.joins(:concept).
      where(exercise_id: exercise_ids).
      pluck(:exercise_id, :'track_concepts.slug').
      each_with_object(Hash.new { |data, exercise_id| data[exercise_id] = [] }) do |(exercise_id, slug), data|
        data[exercise_id] << slug
      end
  end

  def calculate_unlocking!
    tutorial_pending = solutions_data.none? { |_, s| s[:completed_at] }

    @exercises_data.each do |slug, exercise_data|
      # Exercises are unlocked if:
      # - They've started
      # - There are no outstanding prereqs
      # - There is a user track
      unlocked = exercise_is_unlocked?(exercise_data, tutorial_pending)
      solution_data = solutions_data[slug]

      if solution_data
        status = solution_data[:status]
      else
        status = unlocked ? :available : :locked
      end

      exercise_data[:status] = status
      exercise_data[:unlocked] = unlocked
    end
  end

  memoize
  def solutions_data
    return {} if user_track.external?

    # As with the exercises, this plucks to avoid instantiating a Solution and
    # an Exercise for each of the user's solutions on the track.
    user_track.solutions.pluck(:'exercises.slug', :status, :completed_at).
      each_with_object({}) do |(slug, status, completed_at), data|
        data[slug] = {
          slug:,
          status: status.to_sym,
          completed_at: completed_at&.to_i
        }
      end
  end

  def exercise_is_unlocked?(exercise_data, tutorial_pending)
    return true if user_track.external?
    return true if user_track.practice_mode?
    return true if user_track.user.admin?
    return true if solutions_data[exercise_data[:slug]]
    return exercise_data[:tutorial] if tutorial_pending

    ((exercise_data[:prerequisite_concept_slugs] & learnable_concept_slugs) - learnt_concept_slugs).empty?
  end

  memoize
  def unlocked_concept_slugs
    unlocked = exercises_data.select { |_, exercise| exercise[:unlocked] }.
      flat_map { |_, exercise| exercise[:taught_concepts] }

    unlocked + track.concepts.not_taught.pluck(:slug)
  end

  memoize
  def learnt_concept_slugs
    return [] if user_track.external?

    completed_solution_slugs = solutions_data.select { |_, s| s[:completed_at] }.keys
    exercises_data.select { |slug, _| completed_solution_slugs.include?(slug) }.
      flat_map { |_, exercise_data| exercise_data[:taught_concepts] }
  end

  memoize
  def learnable_concept_slugs
    user_track.concept_exercises.joins(:taught_concepts).pluck('track_concepts.slug')
  end
end
