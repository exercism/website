class Track::UpdateBuildStatus
  include Mandate

  initialize_with :track

  def call
    Exercism.redis_tooling_client.set(track.build_status_key, build_status.to_json)
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
      volunteers: serialize_tooling_volunteers(track.test_runner_repo_url)
    }
  end

  def representer
    {
      volunteers: serialize_tooling_volunteers(track.representer_repo_url)
    }
  end

  def analyzer
    {
      display_rate_percentage: percentage(track.submissions.joins(:analysis).count, track.submissions.count),
      volunteers: serialize_tooling_volunteers(track.analyzer_repo_url)
    }
  end

  def syllabus
    {
      concepts:,
      concept_exercises:,
      volunteers: syllabus_volunteers
    }
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
      num_authors: authors.count,
      num_contributors: contributors.count
    }
  end

  NUM_DAYS_FOR_AVERAGE = 30
  private_constant :NUM_DAYS_FOR_AVERAGE
end
