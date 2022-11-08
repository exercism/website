class Track::UpdateBuildStatus
  include Mandate

  initialize_with :track

  def call
    track.build_status = build_status
  end

  private
  def build_status
    {
      volunteers:,
      students:,
      submissions:,
      mentor_discussions:,
      syllabus:,
      practice_exercises:,
      test_runner:,
      representer:,
      analyzer:
    }
  end

  def volunteers
    volunteer_user_ids = User::ReputationPeriod.where(
      period: :forever,
      about: :track,
      track_id: track.id
    ).select(:user_id)

    {
      num_volunteers: volunteer_user_ids.distinct.count,
      users: SerializeAuthorOrContributors.(User.where(id: volunteer_user_ids).order(reputation: :desc).take(12))
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

  def test_runner
    status_counts = track.submissions.where(tests_status: %i[passed failed errored exceptioned]).group(:tests_status).count
    num_passed = status_counts['passed'].to_i
    num_failed = status_counts['failed'].to_i
    num_errored = status_counts['errored'].to_i + status_counts['exceptioned'].to_i
    num_test_runs = num_passed + num_failed + num_errored

    {
      num_test_runs:,
      num_passed:,
      num_failed:,
      num_errored:,
      num_passed_percentage: percentage(num_passed, num_test_runs),
      num_failed_percentage: percentage(num_failed, num_test_runs),
      num_errored_percentage: percentage(num_errored, num_test_runs),
      volunteers: serialize_tooling_volunteers(track.test_runner_repo_url),
      health: test_runner_health,
      version: test_runner_version,
      version_target: test_runner_version_target
    }
  end

  def test_runner_health
    # TODO: use error status to determine health (unhealthy if everything fails)
    return :missing unless track.has_test_runner?
    return :needs_attention if test_runner_version < 2 && track.course?
    return :healthy if test_runner_version < 3 && track.course?

    :exemplar
  end

  memoize
  def test_runner_version = [1, Submission::TestRun.pluck(:version).last.to_i].max

  def test_runner_version_target
    return 1 unless track.has_test_runner?
    return 2 if test_runner_version < 2
    return 3 if test_runner_version < 3 && track.course?
  end

  def representer
    {
      num_representations: Submission::Representation.joins(submission: :exercise).where('exercises.track_id': track.id).count,
      num_comments_made: representer_num_submissions_with_feedback,
      display_rate_percentage: representer_display_rate_percentage,
      volunteers: serialize_tooling_volunteers(track.representer_repo_url),
      health: representer_health
    }
  end

  memoize
  def representer_num_submissions_with_feedback
    Exercise::Representation.with_feedback.joins(:submission_representations).count
  end

  memoize
  def representer_display_rate_percentage
    percentage(representer_num_submissions_with_feedback, track.submissions.count)
  end

  def representer_health
    # TODO: use error status to determine health (unhealthy if everything fails)
    return :missing unless track.has_representer?
    return :needs_attention if representer_display_rate_percentage.zero?

    :exemplar
  end

  def analyzer
    {
      num_comments: Submission::Analysis.joins(submission: :exercise).where(submission: { exercises: { track: } }).sum(:num_comments),
      display_rate_percentage: analyzer_display_rate_percentage,
      volunteers: serialize_tooling_volunteers(track.analyzer_repo_url),
      health: analyzer_health
    }
  end

  memoize
  def analyzer_display_rate_percentage
    percentage(Submission::Analysis.with_comments.where(submission: track.submissions).count, track.submissions.count)
  end

  def analyzer_health
    # TODO: use error status to determine health (unhealthy if everything fails)
    return :missing unless track.has_analyzer?
    return :needs_attention if analyzer_display_rate_percentage.zero?
    return :healthy if analyzer_display_rate_percentage < 5

    :exemplar
  end

  def syllabus
    {
      concepts:,
      concept_exercises:,
      volunteers: syllabus_volunteers,
      health: syllabus_health
    }
  end

  def syllabus_health
    return :missing if active_concept_exercises.empty?
    return :needs_attention if active_concept_exercises.size < 10
    return :needs_attention unless track.course?
    return :healthy if active_concept_exercises.size < 50

    :exemplar
  end

  def syllabus_volunteers
    authors = User.where(id: Concept::Authorship.where(concept: taught_concepts).select(:user_id)).
      or(User.where(id: Exercise::Authorship.where(exercise: active_concept_exercises).select(:user_id)))

    contributors = User.where(id: Concept::Contributorship.where(concept: taught_concepts).select(:user_id)).
      or(User.where(id: Exercise::Contributorship.where(exercise: active_concept_exercises).select(:user_id)))

    serialize_volunteers(authors, contributors)
  end

  def concepts
    {
      num_concepts: taught_concepts.size,
      num_concepts_target: taught_concepts.size, # TODO: implement levels
      created: taught_concepts.map { |concept| serialize_concept(concept) }
    }
  end

  memoize
  def taught_concepts
    taught_concept_ids = Exercise::TaughtConcept.where(exercise: active_concept_exercises).select(:track_concept_id)
    Concept.where(id: taught_concept_ids).to_a
  end

  def concept_exercises
    {
      num_exercises: active_concept_exercises.size,
      num_exercises_target: concept_exercises_num_exercises_target,
      created: active_concept_exercises.map { |exercise| serialize_exercise(exercise) }
    }
  end

  def concept_exercises_num_exercises_target
    NUM_CONCEPT_EXERCISE_TARGETS.find { |target| active_concept_exercises.size < target } || active_concept_exercises.size
  end

  def practice_exercises
    {
      num_exercises: active_practice_exercises.size,
      num_exercises_target: practice_exercises_num_exercises_target,
      created: active_practice_exercises.map { |exercise| serialize_exercise(exercise) },
      volunteers: practice_exercises_volunteers,
      health: practice_exercises_health
    }
  end

  def practice_exercises_num_exercises_target
    num_unimplemented = Track::UnimplementedPracticeExercises.(track.reload).size
    max_target = track.num_exercises + num_unimplemented

    NUM_PRACTICE_EXERCISE_TARGETS.find { |target| active_practice_exercises.size < target } || max_target
  end

  memoize
  def num_unimplemented_practice_exercises
    Track::UnimplementedPracticeExercises.(track).size
  end

  def practice_exercises_volunteers
    authors = User.where(id: Exercise::Authorship.where(exercise: active_practice_exercises).select(:user_id))
    contributors = User.where(id: Exercise::Contributorship.where(exercise: active_practice_exercises).select(:user_id))

    serialize_volunteers(authors, contributors)
  end

  def practice_exercises_health
    return :missing if active_practice_exercises.empty?
    return :exemplar if active_practice_exercises.size >= NUM_PRACTICE_EXERCISE_TARGETS.last
    return :needs_attention if active_practice_exercises.size < NUM_PRACTICE_EXERCISE_TARGETS.first

    :healthy
  end

  memoize
  def active_concept_exercises = track.concept_exercises.where(status: %i[active beta]).order(:title).to_a

  memoize
  def active_practice_exercises = track.practice_exercises.where(status: %i[active beta]).order(:title).to_a

  def average_number_per_day(query, model)
    total_count = query.where("#{model.table_name}.created_at >= ?", Time.current - NUM_DAYS_FOR_AVERAGE.days).count
    (total_count / NUM_DAYS_FOR_AVERAGE.to_f).ceil
  end

  def percentage(count, total_count)
    return 0 if total_count.zero?

    ((count / total_count.to_f) * 100.0).round
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
      num_started: exercise.solutions.count,
      num_submitted: exercise.submissions.count,
      num_completed: exercise.solutions.completed.count,
      links: {
        self: Exercism::Routes.track_exercise_path(track, exercise)
      }
    }
  end

  def serialize_tooling_volunteers(repo_url)
    authors = User.where(id: track.reputation_tokens.where(category: :building).where('external_url LIKE ?',
      "#{repo_url}/%").select(:user_id))
    volunteers = User.where(id: track.reputation_tokens.where(category: :maintaining).where('external_url LIKE ?',
      "#{repo_url}/%").select(:user_id))
    serialize_volunteers(authors, volunteers)
  end

  def serialize_volunteers(authors, contributors)
    {
      users: SerializeAuthorOrContributors.(CombineAuthorsAndContributors.(authors, contributors)),
      num_users: User.where(id: authors.select(:id) + contributors.select(:id)).count
    }
  end

  NUM_DAYS_FOR_AVERAGE = 30
  NUM_PRACTICE_EXERCISE_TARGETS = [10, 20, 30, 40, 50].freeze
  NUM_CONCEPT_EXERCISE_TARGETS = [10, 20, 30, 40, 50].freeze
  private_constant :NUM_DAYS_FOR_AVERAGE, :NUM_PRACTICE_EXERCISE_TARGETS, :NUM_CONCEPT_EXERCISE_TARGETS
end
