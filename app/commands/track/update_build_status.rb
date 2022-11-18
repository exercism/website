class Track::UpdateBuildStatus
  include Mandate

  initialize_with :track

  def call
    track.build_status = build_status
  end

  private
  def build_status
    {
      health:,
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

  def health
    num_exemplar = component_health_statuses[:exemplar].to_i
    num_healthy = component_health_statuses[:healthy].to_i

    return :exemplar if num_exemplar == NUM_COMPONENTS
    return :healthy if num_exemplar + num_healthy == NUM_COMPONENTS

    :needs_attention
  end

  memoize
  def component_health_statuses = [
    analyzer_health,
    test_runner_health,
    representer_health,
    track.course? ? syllabus_health : :exemplar,
    practice_exercises_health
  ].tally

  def volunteers
    track_volunteers = User::ReputationPeriod::Search.(track_id: track.id)
    num_volunteers = track_volunteers.total_count
    top_track_volunteers = track_volunteers.take(NUM_VOLUNTEERS)

    contextual_data = User::ReputationPeriod.
      where(category: :any).
      where(period: :forever).
      where(about: :track, track_id: track.id).
      where(user: top_track_volunteers).
      group(:user_id).
      sum(:reputation).
      transform_values { |reputation| ContributorContextualData.new('', reputation) }

    {
      num_volunteers:,
      users: SerializeContributors.(top_track_volunteers, starting_rank: 1, contextual_data:)
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
      num_submissions:,
      num_submissions_per_day: average_number_per_day(track.submissions, Submission)
    }
  end

  memoize
  def num_submissions = track.submissions.count

  def mentor_discussions
    {
      num_discussions: track.mentor_discussions.count
    }
  end

  def test_runner
    status_counts = track.submissions.group(:tests_status).count
    num_passed = status_counts['passed'].to_i
    num_failed = status_counts['failed'].to_i
    num_errored = status_counts['errored'].to_i + status_counts['exceptioned'].to_i
    num_runs = num_passed + num_failed + num_errored

    {
      num_runs:,
      num_passed:,
      num_failed:,
      num_errored:,
      num_passed_percentage: percentage(num_passed, num_runs),
      num_failed_percentage: percentage(num_failed, num_runs),
      num_errored_percentage: percentage(num_errored, num_runs),
      volunteers: serialize_tooling_volunteers(track.test_runner_repo_url),
      health: test_runner_health,
      version: test_runner_version,
      version_target: test_runner_version_target
    }
  end

  memoize
  def test_runner_health
    # TODO: use error status to determine health (unhealthy if everything fails)
    return :missing unless track.has_test_runner?
    return :needs_attention if test_runner_version < 2 && track.course?
    return :healthy if test_runner_version < 3 && track.course?

    :exemplar
  end

  memoize
  def test_runner_version = [
    1,
    Submission::TestRun.where(track:).order(id: :desc).pick(:version).to_i
  ].max

  def test_runner_version_target
    return 1 unless track.has_test_runner?
    return 2 if test_runner_version < 2
    return 3 if test_runner_version < 3 && track.course?
  end

  def representer
    {
      num_runs: representer_num_runs,
      num_comments: representer_num_submissions_with_feedback,
      display_rate_percentage: representer_display_rate_percentage,
      volunteers: serialize_tooling_volunteers(track.representer_repo_url),
      health: representer_health
    }
  end

  memoize
  def representer_num_runs
    Submission::Representation.where(track:).count
  end

  memoize
  def representer_num_submissions_with_feedback
    Exercise::Representation.with_feedback.joins(:submission_representations).where(track:).count
  end

  memoize
  def representer_num_submissions
    Submission::Representation.where(track:).count
  end

  memoize
  def representer_display_rate_percentage
    percentage(representer_num_submissions_with_feedback, representer_num_submissions)
  end

  memoize
  def representer_health
    # TODO: use error status to determine health (unhealthy if everything fails)
    return :missing unless track.has_representer?
    return :needs_attention if representer_display_rate_percentage.zero?

    :exemplar
  end

  def analyzer
    {
      num_runs: Submission::Analysis.where(track:).count,
      num_comments: Submission::Analysis.where(track:).sum(:num_comments),
      display_rate_percentage: analyzer_display_rate_percentage,
      volunteers: serialize_tooling_volunteers(track.analyzer_repo_url),
      health: analyzer_health
    }
  end

  memoize
  def analyzer_display_rate_percentage
    percentage(Submission::Analysis.with_comments.where(track:).count, num_submissions)
  end

  memoize
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

  memoize
  def syllabus_health
    return :missing if active_concept_exercises.empty?
    return :needs_attention if active_concept_exercises.size < 10
    return :needs_attention unless track.course?
    return :healthy if active_concept_exercises.size < 50

    :exemplar
  end

  def syllabus_volunteers
    authors = User.with_attached_avatar.where(id: Concept::Authorship.where(concept: taught_concepts).select(:user_id)).
      or(User.with_attached_avatar.where(id: Exercise::Authorship.where(exercise: active_concept_exercises).select(:user_id)))

    contributors = User.with_attached_avatar.where(id: Concept::Contributorship.where(concept: taught_concepts).select(:user_id)).
      or(User.with_attached_avatar.where(id: Exercise::Contributorship.where(exercise: active_concept_exercises).select(:user_id)))

    serialize_volunteers(authors, contributors)
  end

  def concepts
    {
      num_concepts: taught_concepts.size,
      num_concepts_target:,
      created: taught_concepts.map { |concept| serialize_concept(concept) }
    }
  end

  def num_concepts_target
    NUM_CONCEPTS_TARGETS.find { |target| taught_concepts.size < target } || taught_concepts.size
  end

  memoize
  def taught_concepts
    Concept.where(id: taught_concepts_ids).sort_by { |c| taught_concepts_ids.index(c.id) }
  end

  memoize
  def taught_concepts_ids = concept_taught_exercise.keys

  memoize
  def concept_taught_exercise
    Exercise::TaughtConcept.
      joins(:exercise, :concept).
      where(exercise: active_concept_exercises).
      order(:position, 'track_concepts.name').
      pluck(:track_concept_id, :exercise_id).
      to_h
  end

  def concept_exercises
    {
      num_exercises: active_concept_exercises.size,
      num_exercises_target: concept_exercises_num_exercises_target,
      created: active_concept_exercises.map { |exercise| serialize_exercise(exercise) }
    }
  end

  def concept_exercises_num_exercises_target
    NUM_CONCEPT_EXERCISES_TARGETS.find { |target| active_concept_exercises.size < target } || active_concept_exercises.size
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
    num_unimplemented = Track::RetrieveUnimplementedPracticeExercises.(track).size
    max_target = track.num_exercises + num_unimplemented

    NUM_PRACTICE_EXERCISES_TARGETS.find { |target| active_practice_exercises.size < target } || max_target
  end

  memoize
  def num_unimplemented_practice_exercises
    Track::RetrieveUnimplementedPracticeExercises.(track).size
  end

  def practice_exercises_volunteers
    authors = User.with_attached_avatar.where(id:
      Exercise::Authorship.where(exercise: active_practice_exercises).select(:user_id))
    contributors = User.with_attached_avatar.where(id:
      Exercise::Contributorship.where(exercise: active_practice_exercises).select(:user_id))

    serialize_volunteers(authors, contributors)
  end

  memoize
  def practice_exercises_health
    return :missing if active_practice_exercises.empty?
    return :exemplar if active_practice_exercises.size >= NUM_PRACTICE_EXERCISES_TARGETS.last
    return :needs_attention if active_practice_exercises.size < NUM_PRACTICE_EXERCISES_TARGETS.first

    :healthy
  end

  memoize
  def active_concept_exercises = track.concept_exercises.where(status: %i[active beta]).order(:position).to_a

  memoize
  def active_practice_exercises = track.practice_exercises.where(status: %i[active beta]).order(:position).to_a

  def average_number_per_day(query, model)
    first_id = query.where("#{model.table_name}.created_at >= ?", Time.current - NUM_DAYS_FOR_AVERAGE.days).pick(:id)
    total_count = query.where("#{model.table_name}.id >= ?", first_id).count
    (total_count / NUM_DAYS_FOR_AVERAGE.to_f).ceil
  end

  def percentage(count, total_count)
    return 0.0 if total_count.zero?

    ((count / total_count.to_f) * 100.0).round(1)
  end

  def average(count, total_count)
    return 0.0 if total_count.zero?

    (count.to_f / total_count).round(1)
  end

  def serialize_concept(concept)
    {
      slug: concept.slug,
      name: concept.name,
      num_students_learnt: exercises_num_completed[concept_taught_exercise[concept.id]].to_i
    }
  end

  def serialize_exercise(exercise)
    num_started = exercises_num_started[exercise.id].to_i
    num_submitted = exercises_num_submitted[exercise.id].to_i
    num_completed = exercises_num_completed[exercise.id].to_i
    num_mentoring_requests = exercises_num_mentoring_requests[exercise.id].to_i

    {
      slug: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url,
      num_started:,
      num_submitted:,
      num_submitted_average: average(num_submitted, num_started),
      num_completed:,
      num_completed_percentage: percentage(num_completed, num_started),
      num_mentoring_requests:,
      num_mentoring_requests_percentage: percentage(num_mentoring_requests, num_started),
      links: {
        self: Exercism::Routes.track_exercise_path(track, exercise)
      }
    }
  end

  def serialize_tooling_volunteers(repo_url)
    authors = User.with_attached_avatar.where(id: track.reputation_tokens.where(category: :building).where('external_url LIKE ?',
      "#{repo_url}/%").select(:user_id))
    volunteers = User.with_attached_avatar.where(id: track.reputation_tokens.where(category: :maintaining).where('external_url LIKE ?',
      "#{repo_url}/%").select(:user_id))
    serialize_volunteers(authors, volunteers)
  end

  def serialize_volunteers(authors, contributors)
    {
      users: SerializeAuthorOrContributors.(CombineAuthorsAndContributors.(authors, contributors)),
      num_users: User.where(id: authors.select(:id) + contributors.select(:id)).count
    }
  end

  memoize
  def exercises_num_started
    Solution.joins(:exercise).where(exercises: { track: }).group(:exercise_id).count
  end

  memoize
  def exercises_num_submitted
    track.submissions.joins(:solution).group(:exercise_id).count
  end

  memoize
  def exercises_num_completed
    Solution.completed.joins(:exercise).where(exercises: { track: }).group(:exercise_id).count
  end

  memoize
  def exercises_num_mentoring_requests
    Mentor::Request.where(track:).group(:exercise_id).count
  end

  ContributorContextualData = Struct.new(:activity, :reputation)

  NUM_COMPONENTS = 5
  NUM_DAYS_FOR_AVERAGE = 30
  NUM_VOLUNTEERS = 12
  NUM_CONCEPTS_TARGETS = [10, 20, 30, 40, 50].freeze
  NUM_PRACTICE_EXERCISES_TARGETS = [10, 20, 30, 40, 50].freeze
  NUM_CONCEPT_EXERCISES_TARGETS = [10, 20, 30, 40, 50].freeze
  private_constant :ContributorContextualData, :NUM_COMPONENTS,
    :NUM_DAYS_FOR_AVERAGE, :NUM_VOLUNTEERS, :NUM_CONCEPTS_TARGETS,
    :NUM_PRACTICE_EXERCISES_TARGETS, :NUM_CONCEPT_EXERCISES_TARGETS
end
