# rubocop:disable Layout/LineLength
require "test_helper"

class Track::UpdateBuildStatusTest < ActiveSupport::TestCase
  test "creates entry if key does not exists" do
    track = create :track
    Exercism.redis_tooling_client.del("track:#{track.id}:build_status")

    # Sanity check
    assert_nil track.build_status

    Track::UpdateBuildStatus.(track)

    refute_nil track.reload.build_status
  end

  test "updates entry if key exists" do
    track = create :track
    Track::UpdateBuildStatus.(track)

    # Sanity check
    assert_equal "needs_attention", track.reload.build_status.health

    track.update(has_analyzer: true)

    Track::UpdateBuildStatus.(track)

    assert_equal "needs_attention", track.reload.build_status.health
  end

  test "submissions" do
    track = create :track
    other_track = create :track, :random_slug

    create_list(:submission, 20, track:, created_at: Time.current - 2.months)
    create_list(:submission, 25, track:, created_at: Time.current - 29.days)
    create_list(:submission, 40, track:, created_at: Time.current - 5.days)
    create_list(:submission, 35, track: other_track, created_at: Time.current - 5.days)

    Track::UpdateBuildStatus.(track)

    assert_equal 85, track.build_status.submissions.num_submissions
  end

  test "mentor_discussions" do
    track = create :track
    create_list(:mentor_request, 16, :fulfilled, track:)

    Track::UpdateBuildStatus.(track)

    assert_equal 16, track.build_status.mentor_discussions.num_discussions
  end

  test "syllabus: concepts" do
    track = create :track, num_concepts: 5

    c_1 = create :concept, track:, slug: 'lists'
    c_2 = create :concept, track:, slug: 'basics'
    c_3 = create :concept, track:, slug: 'switch'
    c_4 = create :concept, track:, slug: 'case'
    c_5 = create :concept, track:, slug: 'arrays'
    c_6 = create :concept, track:, slug: 'finally'

    ce_1 = create :concept_exercise, track:, status: :wip # Ignore wip
    ce_1.taught_concepts << c_1 # Ignore for wip exercise
    ce_2 = create :concept_exercise, track:, status: :beta, position: 2
    ce_2.taught_concepts << c_3
    ce_2.taught_concepts << c_4
    ce_3 = create :concept_exercise, track:, status: :active, position: 1
    ce_3.taught_concepts << c_2
    ce_3.prerequisites << c_5 # Ignore concept if not taught
    ce_4 = create :concept_exercise, track:, status: :deprecated # Ignore deprecated
    ce_4.taught_concepts << c_6 # Ignore for deprecated exercise

    users = create_list(:user, 5)
    create :concept_solution, exercise: ce_2, user: users[0], status: :started
    create :concept_solution, exercise: ce_2, user: users[1], status: :iterated
    create :concept_solution, :completed, exercise: ce_2, user: users[2]
    create :concept_solution, :published, exercise: ce_2, user: users[3]
    create :concept_solution, :published, exercise: ce_2, user: users[4]

    create :concept_solution, exercise: ce_3, user: users[0], status: :started
    create :concept_solution, :completed, exercise: ce_3, user: users[2]

    Track::UpdateBuildStatus.(track)

    assert_equal 3, track.build_status.syllabus.concepts.active.size
    assert_equal 10, track.build_status.syllabus.concepts.num_active_target
    expected_active = [
      { slug: c_2.slug, name: c_2.name, num_students_learnt: 1 },
      { slug: c_4.slug, name: c_4.name, num_students_learnt: 3 },
      { slug: c_3.slug, name: c_3.name, num_students_learnt: 3 }
    ].map(&:to_obj)
    assert_equal expected_active, track.build_status.syllabus.concepts.active
  end

  test "syllabus: concepts: num_active_target" do
    track = create :track
    Track::UpdateBuildStatus.(track)
    assert_equal 10, track.reload.build_status.syllabus.concepts.num_active_target

    create_list(:exercise_taught_concept, 10, exercise: create(:concept_exercise, track:))
    Track::UpdateBuildStatus.(track)
    assert_equal 20, track.reload.build_status.syllabus.concepts.num_active_target

    create_list(:exercise_taught_concept, 10, exercise: create(:concept_exercise, track:))
    Track::UpdateBuildStatus.(track)
    assert_equal 30, track.reload.build_status.syllabus.concepts.num_active_target

    create_list(:exercise_taught_concept, 10, exercise: create(:concept_exercise, track:))
    Track::UpdateBuildStatus.(track)
    assert_equal 40, track.reload.build_status.syllabus.concepts.num_active_target

    create_list(:exercise_taught_concept, 10, exercise: create(:concept_exercise, track:))
    Track::UpdateBuildStatus.(track)
    assert_equal 50, track.reload.build_status.syllabus.concepts.num_active_target

    create_list(:exercise_taught_concept, 26, exercise: create(:concept_exercise, track:))
    Track::UpdateBuildStatus.(track)
    assert_equal 66, track.reload.build_status.syllabus.concepts.num_active_target
  end

  test "syllabus: concept_exercises" do
    track = create :track, num_concepts: 5

    concepts = create_list(:concept, 7, track:)

    ce_1 = create :concept_exercise, track:, status: :wip # Ignore wip
    ce_1.taught_concepts << concepts[0] # Ignore for wip exercise
    ce_2 = create :concept_exercise, track:, status: :beta, slug: 'lasagna', position: 1
    ce_2.taught_concepts << concepts[1]
    ce_3 = create :concept_exercise, track:, status: :active, slug: 'sweethearts', position: 2
    ce_3.taught_concepts << concepts[2]
    ce_3.prerequisites << concepts[5] # Ignore concept if not taught
    ce_4 = create :concept_exercise, track:, status: :deprecated # Ignore deprecated
    ce_4.taught_concepts << concepts[6] # Ignore for deprecated exercise

    users = create_list(:user, 5)
    create :concept_solution, exercise: ce_2, user: users[0], status: :started
    s_2 = create :concept_solution, exercise: ce_2, user: users[1], status: :iterated
    create :submission, exercise: ce_2, user: users[1], solution: s_2
    create :mentor_request, solution: s_2
    s_3 = create :concept_solution, :completed, exercise: ce_2, user: users[2]
    create :submission, exercise: ce_2, user: users[2], solution: s_3
    create :mentor_request, solution: s_3
    s_4 = create :concept_solution, :published, exercise: ce_2, user: users[3]
    create :submission, exercise: ce_2, user: users[3], solution: s_4
    s_5 = create :concept_solution, :published, exercise: ce_2, user: users[4]
    create :submission, exercise: ce_2, user: users[4], solution: s_5
    s_6 = create :concept_solution, exercise: ce_3, user: users[0], status: :started
    create :submission, exercise: ce_3, user: users[0], solution: s_6
    s_7 = create :concept_solution, :completed, exercise: ce_3, user: users[2]
    create :submission, exercise: ce_3, user: users[2], solution: s_7
    create :mentor_request, solution: s_7

    Track::UpdateBuildStatus.(track)

    assert_equal 2, track.build_status.syllabus.concept_exercises.active.size
    expected_active = [
      {
        slug: ce_2.slug,
        title: ce_2.title,
        icon_url: ce_2.icon_url,
        num_started: 5,
        num_submitted: 4,
        num_submitted_average: 0.8,
        num_completed: 3,
        num_completed_percentage: 60,
        num_mentoring_requests: 2,
        num_mentoring_requests_percentage: 40.0,
        links: { self: "/tracks/ruby/exercises/#{ce_2.slug}" }
      },
      {
        slug: ce_3.slug,
        title: ce_3.title,
        icon_url: ce_3.icon_url,
        num_started: 2,
        num_submitted: 2,
        num_submitted_average: 1.0,
        num_completed: 1,
        num_completed_percentage: 50,
        num_mentoring_requests: 1,
        num_mentoring_requests_percentage: 50.0,
        links: { self: "/tracks/ruby/exercises/#{ce_3.slug}" }
      }
    ].map(&:to_obj)
    assert_equal expected_active, track.build_status.syllabus.concept_exercises.active
  end

  test "syllabus: concept_exercises: deprecated" do
    track = create :track

    deprecated_exercise = create :concept_exercise, track:, status: :deprecated

    Track::UpdateBuildStatus.(track)

    assert_equal 1, track.build_status.syllabus.concept_exercises.deprecated.size
    expected = {
      slug: deprecated_exercise.slug,
      title: deprecated_exercise.title,
      icon_url: deprecated_exercise.icon_url,
      num_started: 0,
      num_submitted: 0,
      num_submitted_average: 0.0,
      num_completed: 0,
      num_completed_percentage: 0,
      num_mentoring_requests: 0,
      num_mentoring_requests_percentage: 0.0,
      links: { self: "/tracks/ruby/exercises/#{deprecated_exercise.slug}" }
    }.to_obj
    assert_includes track.build_status.syllabus.concept_exercises.deprecated, expected
  end

  test "syllabus: concept_exercises: num_active_target" do
    track = create :track
    Track::UpdateBuildStatus.(track)
    assert_equal 10, track.reload.build_status.syllabus.concept_exercises.num_active_target

    create_list(:concept_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 20, track.reload.build_status.syllabus.concept_exercises.num_active_target

    create_list(:concept_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 30, track.reload.build_status.syllabus.concept_exercises.num_active_target

    create_list(:concept_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 40, track.reload.build_status.syllabus.concept_exercises.num_active_target

    create_list(:concept_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 50, track.reload.build_status.syllabus.concept_exercises.num_active_target

    create_list(:concept_exercise, 26, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 66, track.reload.build_status.syllabus.concept_exercises.num_active_target
  end

  test "syllabus: health" do
    track = create :track, course: false
    Track::UpdateBuildStatus.(track)
    assert_equal "missing", track.reload.build_status.syllabus.health

    create_list(:concept_exercise, 9, track:) do |exercise|
      create :exercise_taught_concept, exercise:
    end
    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.syllabus.health

    create_list(:concept_exercise, 25, track:) do |exercise|
      create :exercise_taught_concept, exercise:
    end
    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.syllabus.health

    track.update(course: true)
    Track::UpdateBuildStatus.(track)
    assert_equal "healthy", track.reload.build_status.syllabus.health

    create_list(:concept_exercise, 20, track:) do |exercise|
      create :exercise_taught_concept, exercise:
    end
    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.syllabus.health
  end

  test "practice_exercises" do
    track = create :track, num_concepts: 5

    create :practice_exercise, track:, status: :wip # Ignore wip
    pe_2 = create :practice_exercise, track:, status: :beta, slug: 'leap', position: 2
    pe_3 = create :practice_exercise, track:, status: :active, slug: 'anagram', position: 1
    create :practice_exercise, track:, status: :deprecated # Ignore deprecated

    users = create_list(:user, 5)
    create :practice_solution, exercise: pe_2, user: users[0], status: :started
    s_2 = create :practice_solution, exercise: pe_2, user: users[1], status: :iterated
    create :submission, exercise: pe_2, user: users[1], solution: s_2
    create :mentor_request, solution: s_2
    s_3 = create :practice_solution, :completed, exercise: pe_2, user: users[2]
    create :submission, exercise: pe_2, user: users[2], solution: s_3
    create :mentor_request, solution: s_3
    s_4 = create :practice_solution, :published, exercise: pe_2, user: users[3]
    create :submission, exercise: pe_2, user: users[3], solution: s_4
    s_5 = create :practice_solution, :published, exercise: pe_2, user: users[4]
    create :submission, exercise: pe_2, user: users[4], solution: s_5
    s_6 = create :practice_solution, exercise: pe_3, user: users[0], status: :started
    create :submission, exercise: pe_3, user: users[0], solution: s_6
    s_7 = create :practice_solution, :completed, exercise: pe_3, user: users[2]
    create :submission, exercise: pe_3, user: users[2], solution: s_7
    create :mentor_request, solution: s_7

    Track::UpdateBuildStatus.(track)

    assert_equal 2, track.build_status.practice_exercises.active.size
    expected_active = [
      {
        slug: pe_3.slug,
        title: pe_3.title,
        icon_url: pe_3.icon_url,
        num_started: 2,
        num_submitted: 2,
        num_submitted_average: 1.0,
        num_completed: 1,
        num_completed_percentage: 50,
        num_mentoring_requests: 1,
        num_mentoring_requests_percentage: 50.0,
        links: { self: "/tracks/ruby/exercises/#{pe_3.slug}" }
      },
      {
        slug: pe_2.slug,
        title: pe_2.title,
        icon_url: pe_2.icon_url,
        num_started: 5,
        num_submitted: 4,
        num_submitted_average: 0.8,
        num_completed: 3,
        num_completed_percentage: 60,
        num_mentoring_requests: 2,
        num_mentoring_requests_percentage: 40.0,
        links: { self: "/tracks/ruby/exercises/#{pe_2.slug}" }
      }
    ].map(&:to_obj)
    assert_equal expected_active, track.build_status.practice_exercises.active
  end

  test "practice_exercises: deprecated" do
    track = create :track

    deprecated_exercise = create :practice_exercise, track:, status: :deprecated

    Track::UpdateBuildStatus.(track)

    assert_equal 1, track.build_status.practice_exercises.deprecated.size
    expected = {
      slug: deprecated_exercise.slug,
      title: deprecated_exercise.title,
      icon_url: deprecated_exercise.icon_url,
      num_started: 0,
      num_submitted: 0,
      num_submitted_average: 0.0,
      num_completed: 0,
      num_completed_percentage: 0,
      num_mentoring_requests: 0,
      num_mentoring_requests_percentage: 0.0,
      links: { self: "/tracks/ruby/exercises/#{deprecated_exercise.slug}" }
    }.to_obj
    assert_includes track.build_status.practice_exercises.deprecated, expected
  end

  test "practice_exercises: unimplemented" do
    fix_prob_specs_repo_sha

    Git::SyncProblemSpecifications.()

    track = create :track

    Track::UpdateBuildStatus.(track)

    assert_equal 125, track.build_status.practice_exercises.unimplemented.size
    expected = {
      slug: "zebra-puzzle",
      title: "Zebra Puzzle",
      icon_url: "https://assets.exercism.org/exercises/zebra-puzzle.svg",
      links: {
        self: "https://github.com/exercism/problem-specifications/tree/main/exercises/zebra-puzzle"
      }
    }.to_obj
    assert_includes track.build_status.practice_exercises.unimplemented, expected
  end

  test "practice_exercises: foregone" do
    fix_prob_specs_repo_sha

    Git::SyncProblemSpecifications.()

    track = create :track

    Track::UpdateBuildStatus.(track)

    assert_equal 2, track.build_status.practice_exercises.foregone.size
    expected = {
      slug: "alphametics",
      title: "Alphametics",
      icon_url: "https://assets.exercism.org/exercises/alphametics.svg",
      links: {
        self: "https://github.com/exercism/problem-specifications/tree/main/exercises/alphametics"
      }
    }.to_obj
    assert_includes track.build_status.practice_exercises.foregone, expected
  end

  test "practice_exercises: num_active_target" do
    fix_prob_specs_repo_sha

    Git::SyncProblemSpecifications.()

    track = create :track
    Track::UpdateBuildStatus.(track)
    assert_equal 20, track.reload.build_status.practice_exercises.num_active_target

    create_list(:practice_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 20, track.reload.build_status.practice_exercises.num_active_target

    create_list(:practice_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 30, track.reload.build_status.practice_exercises.num_active_target

    create_list(:practice_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 40, track.reload.build_status.practice_exercises.num_active_target

    create_list(:practice_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 50, track.reload.build_status.practice_exercises.num_active_target

    create_list(:practice_exercise, 30, track:)
    Track::UpdateBuildStatus.(track)

    # Sanity check: concept exercises don't count
    create_list(:concept_exercise, 3, track:)
    Track::UpdateBuildStatus.(track)

    # Sanity check: wip practice exercises don't count
    create_list(:practice_exercise, 2, status: :wip, track:)
    Track::UpdateBuildStatus.(track)

    # Sanity check: deprecated practice exercises don't count
    create_list(:practice_exercise, 2, status: :deprecated, track:)
    Track::UpdateBuildStatus.(track)

    assert_equal 194, track.reload.build_status.practice_exercises.num_active_target
  end

  test "practice_exercises: health" do
    track = create :track
    Track::UpdateBuildStatus.(track)
    assert_equal "missing", track.reload.build_status.practice_exercises.health

    create_list(:practice_exercise, 9, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.practice_exercises.health

    create_list(:practice_exercise, 25, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal "healthy", track.reload.build_status.practice_exercises.health

    create_list(:practice_exercise, 20, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.practice_exercises.health
  end

  test "test_runner" do
    track = create :track

    create_list(:submission, 2, tests_status: :not_queued, solution: create(:practice_solution, track:)) # Ignore
    create_list(:submission, 3, tests_status: :queued, solution: create(:practice_solution, track:)) # Ignore
    create_list(:submission, 5, tests_status: :passed, solution: create(:practice_solution, track:))
    create_list(:submission, 7, tests_status: :failed, solution: create(:practice_solution, track:))
    create_list(:submission, 11, tests_status: :errored, solution: create(:practice_solution, track:))
    create_list(:submission, 13, tests_status: :exceptioned, solution: create(:practice_solution, track:))
    create_list(:submission, 17, tests_status: :cancelled, solution: create(:practice_solution, track:)) # Ignore
    create_list(:submission, 19, tests_status: :passed, solution: create(:practice_solution, track: create(:track, :random_slug)))

    Track::UpdateBuildStatus.(track)

    assert_equal 36, track.build_status.test_runner.num_runs
    assert_equal 5, track.build_status.test_runner.num_passed
    assert_equal 7, track.build_status.test_runner.num_failed
    assert_equal 24, track.build_status.test_runner.num_errored
    assert_equal 13.9, track.build_status.test_runner.num_passed_percentage
    assert_equal 19.4, track.build_status.test_runner.num_failed_percentage
    assert_equal 66.7, track.build_status.test_runner.num_errored_percentage
  end

  test "test_runner: version" do
    track = create :track

    Track::UpdateBuildStatus.(track)
    assert_equal 1, track.reload.build_status.test_runner.version

    create :submission_test_run, submission: (create :submission, track:), raw_results: {}
    Track::UpdateBuildStatus.(track)
    assert_equal 1, track.reload.build_status.test_runner.version

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 1, status: 'pass' }
    Track::UpdateBuildStatus.(track)
    assert_equal 1, track.reload.build_status.test_runner.version

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 2, status: 'pass' }
    Track::UpdateBuildStatus.(track)
    assert_equal 2, track.reload.build_status.test_runner.version

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 3, status: 'pass' }
    Track::UpdateBuildStatus.(track)
    assert_equal 3, track.reload.build_status.test_runner.version

    # Sanity check: ignore timed-out test runs
    create :submission_test_run, :timed_out, submission: (create :submission, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 3, track.reload.build_status.test_runner.version
  end

  test "test_runner: version_target" do
    track = create :track
    other_track = create :track, :random_slug

    track.update(has_test_runner: false)
    Track::UpdateBuildStatus.(track)
    assert_equal 1, track.reload.build_status.test_runner.version_target

    track.update(has_test_runner: true)
    Track::UpdateBuildStatus.(track)
    assert_equal 2, track.reload.build_status.test_runner.version_target

    create :submission_test_run, submission: (create :submission, track:), raw_results: {}
    Track::UpdateBuildStatus.(track)
    assert_equal 2, track.reload.build_status.test_runner.version_target

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 1, status: 'pass' }
    Track::UpdateBuildStatus.(track)
    assert_equal 2, track.reload.build_status.test_runner.version_target

    track.update(course: false)
    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 2, status: 'pass' }
    Track::UpdateBuildStatus.(track)
    assert_nil track.reload.build_status.test_runner.version_target

    track.update(course: true)
    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 2, status: 'pass' }
    Track::UpdateBuildStatus.(track)
    assert_equal 3, track.reload.build_status.test_runner.version_target

    # Ignore submissions from other track
    create :submission_test_run, submission: (create :submission, track: other_track), raw_results: { version: 1, status: 'pass' }
    Track::UpdateBuildStatus.(track)
    assert_equal 3, track.reload.build_status.test_runner.version_target

    # Sanity check: ignore timed-out test runs
    create :submission_test_run, :timed_out, submission: (create :submission, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 3, track.reload.build_status.test_runner.version_target

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 3, status: 'pass' }
    Track::UpdateBuildStatus.(track)
    assert_nil track.reload.build_status.test_runner.version_target
  end

  test "test_runner: health" do
    track = create :track, has_test_runner: false
    Track::UpdateBuildStatus.(track)
    assert_equal "missing", track.reload.build_status.test_runner.health

    track.update(has_test_runner: true, course: false)
    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.test_runner.health

    track.update(course: true)
    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 1, status: 'pass' }
    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.test_runner.health

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 2, status: 'pass' }
    Track::UpdateBuildStatus.(track)
    assert_equal "healthy", track.reload.build_status.test_runner.health

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 3, status: 'pass' }
    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.test_runner.health
  end

  test "representer" do
    track = create :track
    other_track = create :track, :random_slug

    20.times do
      submission = create(:submission, track:)
      create :submission_representation, submission:
    end

    # 3 more submissions with matching ast_digest
    create_list(:submission_representation, 3, submission: Submission.last,
      ast_digest: Submission::Representation.last.ast_digest)

    create :exercise_representation, :with_feedback, source_submission: Submission.last,
      ast_digest: Submission::Representation.last.ast_digest
    create :exercise_representation, :with_feedback, source_submission: Submission.first,
      ast_digest: Submission::Representation.first.ast_digest

    # Sanity check: ignore representation without feedback
    create :exercise_representation, source_submission: create(:submission, track:), ast_digest: SecureRandom.uuid

    # Sanity check: ignore other tracks
    create_list(:submission_representation, 3, submission: create(:submission, track: other_track)) do |submission_representation|
      create :exercise_representation, source_submission: submission_representation.submission,
        ast_digest: submission_representation.ast_digest
    end

    Track::UpdateBuildStatus.(track)

    assert_equal 23, track.build_status.representer.num_runs
    assert_equal 5, track.build_status.representer.num_comments
    assert_equal 21.7, track.build_status.representer.display_rate_percentage
  end

  test "representer: health" do
    track = create :track, has_representer: false
    Track::UpdateBuildStatus.(track)
    assert_equal "missing", track.reload.build_status.representer.health

    track.update(has_representer: true)
    submission = create(:submission, track:)
    submission_representation = create(:submission_representation, submission:)
    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.representer.health

    create :exercise_representation, :with_feedback, source_submission: submission,
      ast_digest: submission_representation.ast_digest
    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.representer.health
  end

  test "analyzer" do
    track = create :track

    s_1 = create(:submission, track:)
    create :submission_analysis, :with_comments, submission: s_1
    s_2 = create(:submission, track:)
    create :submission_analysis, :with_comments, submission: s_2
    s_3 = create(:submission, track:)
    create :submission_analysis, submission: s_3 # No comments
    create_list(:submission, 3, track:)
    create_list(:submission, 4, track: create(:track, :random_slug))
    s_4 = create :submission, track: create(:track, :random_slug)
    create :submission_analysis, :with_comments, submission: s_4

    Track::UpdateBuildStatus.(track)

    assert_equal 3, track.build_status.analyzer.num_runs
    assert_equal 4, track.build_status.analyzer.num_comments
    assert_equal 33.3, track.build_status.analyzer.display_rate_percentage
  end

  test "analyzer: health" do
    track = create :track, has_analyzer: false
    Track::UpdateBuildStatus.(track)
    assert_equal "missing", track.reload.build_status.analyzer.health

    track.update(has_analyzer: true)
    create_list(:submission, 30, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.analyzer.health

    submission = create(:submission, track:)
    create(:submission_analysis, :with_comments, submission:)
    Track::UpdateBuildStatus.(track)
    assert_equal "healthy", track.reload.build_status.analyzer.health

    create_list(:submission, 10, track:) do
      create :submission_analysis, :with_comments, submission:
    end
    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.analyzer.health
  end

  test "health: exemplar" do
    track = create :track

    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.health

    # analyzer_health: :exemplar
    track.update(has_analyzer: true)
    submission = create(:submission, track:)
    create(:submission_analysis, :with_comments, submission:)

    # representer_health: :exemplar
    track.update(has_representer: true)
    submission_representation = create(:submission_representation, submission:)
    create :exercise_representation, :with_feedback, source_submission: submission, ast_digest: submission_representation.ast_digest

    # test_runner_health: :exemplar
    track.update(has_representer: true)
    create :submission_test_run, submission:, raw_results: { version: 3, status: 'pass' }

    # practice_exercises_health: :exemplar
    track.update(course: false)
    create_list(:practice_exercise, 50, track:)

    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.health

    # syllabus_health: :exemplar
    track.update(course: true)
    create_list(:concept_exercise, 50, track:) do |exercise|
      create :exercise_taught_concept, exercise:
    end

    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.health

    # practice_exercises_health: :healthy
    PracticeExercise.limit(20).delete_all

    Track::UpdateBuildStatus.(track)
    assert_equal "healthy", track.reload.build_status.health
  end

  private
  def fix_prob_specs_repo_sha
    git_prob_specs_repo = Git::Repository.new(repo_url: Git::ProblemSpecifications::DEFAULT_REPO_URL, branch_ref: "957c0c258679ad78a38aa12bc475d72a3debd279")
    git_prob_specs = Git::ProblemSpecifications.new(repo: git_prob_specs_repo)
    Git::ProblemSpecifications.stubs(:new).returns(git_prob_specs)
  end
end
# rubocop:enable Layout/LineLength
