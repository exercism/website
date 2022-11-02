class Track::UpdateBuildStatus
  include Mandate

  initialize_with :track

  def call
    Exercism.redis_tooling_client.set(track.build_status_key, build_status.to_json)
  end

  private
  def build_status
    {
      students:,
      submissions:,
      mentor_discussions:,
      syllabus:,
      practice_exercises:
    }
  end

  def students
    {
      num_students: track.num_students,
      num_students_per_day: average_number_per_day(track.user_tracks, UserTrack)
    }
  end

  def submissions
    {
      num_submissions: track.submissions.count,
      num_submissions_per_day: average_number_per_day(track.submissions, Submission)
    }
  end

  def mentor_discussions
    {
      num_discussions: track.mentor_discussions.count
    }
  end

  def syllabus
    {
      concepts:,
      concept_exercises:
    }
  end

  def concepts
    taught_concept_ids = Exercise::TaughtConcept.where(exercise: active_concept_exercises).select(:track_concept_id)
    taught_concepts = Concept.where(id: taught_concept_ids).to_a

    {
      num_concepts: taught_concepts.size,
      num_concepts_target: taught_concepts.size, # TODO: implement levels
      created: taught_concepts.map { |concept| serialize_concept(concept) }
    }
  end

  def concept_exercises
    {
      num_exercises: active_concept_exercises.size,
      num_exercises_target: active_concept_exercises.size, # TODO: implement levels
      created: active_concept_exercises.map { |exercise| serialize_exercise(exercise) }
    }
  end

  def practice_exercises
    {
      num_exercises: active_practice_exercises.size,
      num_exercises_target: active_practice_exercises.size, # TODO: implement levels
      created: active_practice_exercises.map { |exercise| serialize_exercise(exercise) }
    }
  end

  memoize
  def active_concept_exercises = track.concept_exercises.where(status: %i[active beta]).order(:title).to_a

  memoize
  def active_practice_exercises = track.practice_exercises.where(status: %i[active beta]).order(:title).to_a

  def average_number_per_day(query, model)
    total_count = query.where("#{model.table_name}.created_at >= ?", Time.current - NUM_DAYS_FOR_AVERAGE.days).count
    (total_count / NUM_DAYS_FOR_AVERAGE.to_f).ceil
  end

  def serialize_concept(concept)
    {
      slug: concept.slug,
      name: concept.name,
      # TODO: prevent N+1
      num_students_learnt: Solution.completed.where(exercise_id: Exercise::TaughtConcept.where(concept:).select(:exercise_id)).count
    }
  end

  def serialize_exercise(exercise)
    {
      slug: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url,
      stats: {
        num_started: exercise.solutions.count,
        num_submitted: exercise.submissions.count,
        num_completed: exercise.solutions.completed.count
      },
      links: {
        self: Exercism::Routes.track_exercise_path(track, exercise)
      }
    }
  end

  NUM_DAYS_FOR_AVERAGE = 30
  private_constant :NUM_DAYS_FOR_AVERAGE
end
