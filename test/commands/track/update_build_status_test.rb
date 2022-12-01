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
    assert_equal 0, track.reload.build_status.students.num_students

    track.update(num_students: 33)
    Track::UpdateBuildStatus.(track)

    assert_equal 33, track.reload.build_status.students.num_students
  end

  test "students" do
    track = create :track

    create_list(:user_track, 20, track:, created_at: Time.current - 2.months)
    create_list(:user_track, 40, track:, created_at: Time.current - 29.days)
    create_list(:user_track, 30, track:, created_at: Time.current - 5.days)
    create_list(:user_track, 30, track: (create :track, :random_slug), created_at: Time.current - 5.days)

    Track::UpdateBuildStatus.(track)

    assert_equal 90, track.build_status.students.num_students
    assert_equal 3, track.build_status.students.num_students_per_day
  end

  test "submissions" do
    track = create :track
    other_track = create :track, :random_slug

    create_list(:submission, 20, track:, created_at: Time.current - 2.months)
    create_list(:submission, 25, track:, created_at: Time.current - 29.days)
    create_list(:submission, 40, track:, created_at: Time.current - 5.days)
    create_list(:submission, 35, track: other_track, created_at: Time.current - 5.days)

    (1..30).each do |day|
      create :metric_period_day, metric_type: Metrics::SubmitSubmissionMetric.name, day:, count: day, track: track
      create :metric_period_day, metric_type: Metrics::SubmitSubmissionMetric.name, day:, count: 5, track: other_track
    end

    Track::UpdateBuildStatus.(track)

    assert_equal 85, track.build_status.submissions.num_submissions
    assert_equal 15.5, track.build_status.submissions.num_submissions_per_day
  end

  test "mentor_discussions" do
    track = create :track
    create_list(:mentor_discussion, 16, track:)

    Track::UpdateBuildStatus.(track)

    assert_equal 16, track.build_status.mentor_discussions.num_discussions
  end

  test "volunteers" do
    track = create :track

    user_1 = create :user, reputation: 67
    user_2 = create :user, reputation: 113
    user_3 = create :user, reputation: 20
    user_4 = create :user, reputation: 555
    user_5 = create :user, reputation: 532
    user_6 = create :user, reputation: 98

    period_1 = create :user_reputation_period, track_id: track.id, user: user_1, about: :track, category: :any,
      reputation: 300
    period_2 = create :user_reputation_period, track_id: track.id, user: user_2, about: :track, category: :any,
      reputation: 20
    period_3 = create :user_reputation_period, track_id: track.id, user: user_3, about: :track, category: :any,
      reputation: 44
    period_4 = create :user_reputation_period, track_id: track.id, user: user_4, about: :track, category: :any,
      reputation: 33
    period_5 = create :user_reputation_period, track_id: track.id, user: user_5, about: :track, category: :any,
      reputation: 97
    create :user_reputation_period, user: user_6, reputation: 10 # Ignore: no track

    Track::UpdateBuildStatus.(track)

    assert_equal 5, track.build_status.volunteers.num_volunteers
    expected_users = [
      { rank: 1, activity: '', handle: user_1.handle, reputation: period_1.reputation.to_s,
        avatar_url: user_1.avatar_url, links: { profile: nil } },
      { rank: 2, activity: '', handle: user_5.handle, reputation: period_5.reputation.to_s,
        avatar_url: user_5.avatar_url, links: { profile: nil } },
      { rank: 3, activity: '', handle: user_3.handle, reputation: period_3.reputation.to_s,
        avatar_url: user_3.avatar_url, links: { profile: nil } },
      { rank: 4, activity: '', handle: user_4.handle, reputation: period_4.reputation.to_s,
        avatar_url: user_4.avatar_url, links: { profile: nil } },
      { rank: 5, activity: '', handle: user_2.handle, reputation: period_2.reputation.to_s, avatar_url: user_2.avatar_url,
        links: { profile: nil } }
    ].map(&:to_obj)
    assert_equal expected_users, track.build_status.volunteers.users
  end

  test "syllabus: volunteers" do
    track = create :track

    users = create_list(:user, 7)
    concepts = create_list(:concept, 2)
    concept_exercises = create_list(:concept_exercise, 3)

    concept_exercises[0].taught_concepts << concepts[0]

    concepts[0].authors << users[0]
    concepts[0].authors << users[1]
    concepts[0].contributors << users[2]

    concept_exercises[0].authors << users[3]
    concept_exercises[0].contributors << users[2]
    concept_exercises[1].contributors << users[4]

    Track::UpdateBuildStatus.(track)

    expected_users = [
      { name: users[0].name, handle: users[0].handle, avatar_url: users[0].avatar_url,
        reputation: users[0].reload.formatted_reputation, links: { profile: nil } },
      { name: users[1].name, handle: users[1].handle, avatar_url: users[1].avatar_url,
        reputation: users[1].reload.formatted_reputation, links: { profile: nil } },
      { name: users[3].name, handle: users[3].handle, avatar_url: users[3].avatar_url,
        reputation: users[3].reload.formatted_reputation, links: { profile: nil } }
    ].map(&:to_obj)
    assert_equal 5, track.build_status.syllabus.volunteers.num_users
    assert_equal 3, track.build_status.syllabus.volunteers.users.size
    expected_users.each do |expected_user|
      assert_includes track.build_status.syllabus.volunteers.users, expected_user
    end
  end

  test "syllabus: concepts" do
    track = create :track, num_concepts: 5

    c_1 = create :concept, track: track, slug: 'lists'
    c_2 = create :concept, track: track, slug: 'basics'
    c_3 = create :concept, track: track, slug: 'switch'
    c_4 = create :concept, track: track, slug: 'case'
    c_5 = create :concept, track: track, slug: 'arrays'
    c_6 = create :concept, track: track, slug: 'finally'

    ce_1 = create :concept_exercise, track: track, status: :wip # Ignore wip
    ce_1.taught_concepts << c_1 # Ignore for wip exercise
    ce_2 = create :concept_exercise, track: track, status: :beta, position: 2
    ce_2.taught_concepts << c_3
    ce_2.taught_concepts << c_4
    ce_3 = create :concept_exercise, track: track, status: :active, position: 1
    ce_3.taught_concepts << c_2
    ce_3.prerequisites << c_5 # Ignore concept if not taught
    ce_4 = create :concept_exercise, track: track, status: :deprecated # Ignore deprecated
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

    assert_equal 3, track.build_status.syllabus.concepts.num_concepts
    assert_equal 10, track.build_status.syllabus.concepts.num_concepts_target
    expected_created = [
      { slug: c_2.slug, name: c_2.name, num_students_learnt: 1 },
      { slug: c_4.slug, name: c_4.name, num_students_learnt: 3 },
      { slug: c_3.slug, name: c_3.name, num_students_learnt: 3 }
    ].map(&:to_obj)
    assert_equal expected_created, track.build_status.syllabus.concepts.created
  end

  test "syllabus: concepts: num_concepts_target" do
    track = create :track
    Track::UpdateBuildStatus.(track)
    assert_equal 10, track.reload.build_status.syllabus.concepts.num_concepts_target

    create_list(:exercise_taught_concept, 10, exercise: create(:concept_exercise, track:))
    Track::UpdateBuildStatus.(track)
    assert_equal 20, track.reload.build_status.syllabus.concepts.num_concepts_target

    create_list(:exercise_taught_concept, 10, exercise: create(:concept_exercise, track:))
    Track::UpdateBuildStatus.(track)
    assert_equal 30, track.reload.build_status.syllabus.concepts.num_concepts_target

    create_list(:exercise_taught_concept, 10, exercise: create(:concept_exercise, track:))
    Track::UpdateBuildStatus.(track)
    assert_equal 40, track.reload.build_status.syllabus.concepts.num_concepts_target

    create_list(:exercise_taught_concept, 10, exercise: create(:concept_exercise, track:))
    Track::UpdateBuildStatus.(track)
    assert_equal 50, track.reload.build_status.syllabus.concepts.num_concepts_target

    create_list(:exercise_taught_concept, 26, exercise: create(:concept_exercise, track:))
    Track::UpdateBuildStatus.(track)
    assert_equal 66, track.reload.build_status.syllabus.concepts.num_concepts_target
  end

  test "syllabus: concept_exercises" do
    track = create :track, num_concepts: 5

    concepts = create_list(:concept, 7, track:)

    ce_1 = create :concept_exercise, track: track, status: :wip # Ignore wip
    ce_1.taught_concepts << concepts[0] # Ignore for wip exercise
    ce_2 = create :concept_exercise, track: track, status: :beta, slug: 'lasagna', position: 1
    ce_2.taught_concepts << concepts[1]
    ce_3 = create :concept_exercise, track: track, status: :active, slug: 'sweethearts', position: 2
    ce_3.taught_concepts << concepts[2]
    ce_3.prerequisites << concepts[5] # Ignore concept if not taught
    ce_4 = create :concept_exercise, track: track, status: :deprecated # Ignore deprecated
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

    assert_equal 2, track.build_status.syllabus.concept_exercises.num_exercises
    expected_created = [
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
    assert_equal expected_created, track.build_status.syllabus.concept_exercises.created
  end

  test "syllabus: concept_exercises: num_exercises_target" do
    track = create :track
    Track::UpdateBuildStatus.(track)
    assert_equal 10, track.reload.build_status.syllabus.concept_exercises.num_exercises_target

    create_list(:concept_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 20, track.reload.build_status.syllabus.concept_exercises.num_exercises_target

    create_list(:concept_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 30, track.reload.build_status.syllabus.concept_exercises.num_exercises_target

    create_list(:concept_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 40, track.reload.build_status.syllabus.concept_exercises.num_exercises_target

    create_list(:concept_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 50, track.reload.build_status.syllabus.concept_exercises.num_exercises_target

    create_list(:concept_exercise, 26, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 66, track.reload.build_status.syllabus.concept_exercises.num_exercises_target
  end

  test "syllabus: health" do
    track = create :track, course: false
    Track::UpdateBuildStatus.(track)
    assert_equal "missing", track.reload.build_status.syllabus.health

    create_list(:concept_exercise, 9, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.syllabus.health

    create_list(:concept_exercise, 25, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.syllabus.health

    track.update(course: true)
    Track::UpdateBuildStatus.(track)
    assert_equal "healthy", track.reload.build_status.syllabus.health

    create_list(:concept_exercise, 20, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.syllabus.health
  end

  test "practice_exercises" do
    track = create :track, num_concepts: 5

    create :practice_exercise, track: track, status: :wip # Ignore wip
    pe_2 = create :practice_exercise, track: track, status: :beta, slug: 'leap', position: 2
    pe_3 = create :practice_exercise, track: track, status: :active, slug: 'anagram', position: 1
    create :practice_exercise, track: track, status: :deprecated # Ignore deprecated

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

    assert_equal 2, track.build_status.practice_exercises.num_exercises
    expected_created = [
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
    assert_equal expected_created, track.build_status.practice_exercises.created
  end

  test "practice_exercises: unimplemented" do
    track = create :track

    Track::UpdateBuildStatus.(track)

    assert_equal 126, track.build_status.practice_exercises.num_unimplemented
    expected = {
      slug: "zebra-puzzle",
      title: "Zebra Puzzle",
      icon_url: "https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/zebra-puzzle.svg",
      links: {
        self: "https://github.com/exercism/problem-specifications/tree/main/exercises/zebra-puzzle"
      }
    }.to_obj
    assert_includes track.build_status.practice_exercises.unimplemented, expected
  end

  test "practice_exercises: foregone" do
    track = create :track

    Track::UpdateBuildStatus.(track)

    assert_equal 2, track.build_status.practice_exercises.num_foregone
    expected = {
      slug: "alphametics",
      title: "Alphametics",
      icon_url: "https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/alphametics.svg",
      links: {
        self: "https://github.com/exercism/problem-specifications/tree/main/exercises/alphametics"
      }
    }.to_obj
    assert_includes track.build_status.practice_exercises.foregone, expected
  end

  test "practice_exercises: num_exercises_target" do
    track = create :track
    Track::UpdateBuildStatus.(track)
    assert_equal 10, track.reload.build_status.practice_exercises.num_exercises_target

    create_list(:practice_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 20, track.reload.build_status.practice_exercises.num_exercises_target

    create_list(:practice_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 30, track.reload.build_status.practice_exercises.num_exercises_target

    create_list(:practice_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 40, track.reload.build_status.practice_exercises.num_exercises_target

    create_list(:practice_exercise, 10, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal 50, track.reload.build_status.practice_exercises.num_exercises_target

    create_list(:practice_exercise, 30, track:)
    Track::UpdateBuildStatus.(track)

    num_unimplemented = Track::RetrieveUnimplementedPracticeExercises.(track.reload).size
    assert_equal track.num_exercises + num_unimplemented, track.reload.build_status.practice_exercises.num_exercises_target
  end

  test "practice_exercises: volunteers" do
    track = create :track

    users = create_list(:user, 5)
    practice_exercises = create_list(:practice_exercise, 4)

    practice_exercises[0].authors << users[3]
    practice_exercises[0].contributors << users[2]
    practice_exercises[1].authors << users[4]
    practice_exercises[2].authors << users[1]
    practice_exercises[3].contributors << users[1]

    Track::UpdateBuildStatus.(track)

    expected_users = [
      { name: users[1].name, handle: users[1].handle, avatar_url: users[1].avatar_url,
        reputation: users[1].reload.formatted_reputation, links: { profile: nil } },
      { name: users[3].name, handle: users[3].handle, avatar_url: users[3].avatar_url,
        reputation: users[3].reload.formatted_reputation, links: { profile: nil } },
      { name: users[4].name, handle: users[4].handle, avatar_url: users[4].avatar_url,
        reputation: users[4].reload.formatted_reputation, links: { profile: nil } }
    ].map(&:to_obj)
    assert_equal 4, track.build_status.practice_exercises.volunteers.num_users
    assert_equal 3, track.build_status.practice_exercises.volunteers.users.size
    expected_users.each do |expected_user|
      assert_includes track.build_status.practice_exercises.volunteers.users, expected_user
    end
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

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 1 }
    Track::UpdateBuildStatus.(track)
    assert_equal 1, track.reload.build_status.test_runner.version

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 2 }
    Track::UpdateBuildStatus.(track)
    assert_equal 2, track.reload.build_status.test_runner.version

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 3 }
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

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 1 }
    Track::UpdateBuildStatus.(track)
    assert_equal 2, track.reload.build_status.test_runner.version_target

    track.update(course: false)
    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 2 }
    Track::UpdateBuildStatus.(track)
    assert_nil track.reload.build_status.test_runner.version_target

    track.update(course: true)
    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 2 }
    Track::UpdateBuildStatus.(track)
    assert_equal 3, track.reload.build_status.test_runner.version_target

    # Ignore submissions from other track
    create :submission_test_run, submission: (create :submission, track: other_track), raw_results: { version: 1 }
    Track::UpdateBuildStatus.(track)
    assert_equal 3, track.reload.build_status.test_runner.version_target

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 3 }
    Track::UpdateBuildStatus.(track)
    assert_nil track.reload.build_status.test_runner.version_target
  end

  test "test_runner: volunteers" do
    track = create :track, repo_url: 'https://github.com/exercism/ruby'
    other_track = create :track, :random_slug

    users = create_list(:user, 7)
    create :user_code_contribution_reputation_token, track: track, user: users[0], external_url: "#{track.test_runner_repo_url}/pull/1"
    create :user_code_contribution_reputation_token, track: track, user: users[1], external_url: "#{track.test_runner_repo_url}/pull/1"
    create :user_code_merge_reputation_token, track: track, user: users[2], external_url: "#{track.test_runner_repo_url}/pull/1"
    create :user_code_review_reputation_token, track: track, user: users[3], external_url: "#{track.test_runner_repo_url}/pull/2"
    create :user_code_review_reputation_token, track: track, user: users[4], external_url: "#{track.test_runner_repo_url}/pull/3"

    # Ignore tokens for track, analyzer and representers repo
    create :user_code_merge_reputation_token, track: track, user: users[6], external_url: "#{track.repo_url}/pull/4"
    create :user_code_merge_reputation_token, track: track, user: users[6], external_url: "#{track.analyzer_repo_url}/pull/5"
    create :user_code_merge_reputation_token, track: track, user: users[6], external_url: "#{track.representer_repo_url}/pull/6"

    # Ignore other track
    create :user_code_merge_reputation_token, track: other_track, user: users[0], external_url: other_track.test_runner_repo_url

    Track::UpdateBuildStatus.(track)

    assert_equal 5, track.build_status.test_runner.volunteers.num_users
    assert_equal 3, track.build_status.test_runner.volunteers.users.size
    expected_users = [
      { name: users[0].name, handle: users[0].handle, avatar_url: users[0].avatar_url,
        reputation: users[0].reload.formatted_reputation, links: { profile: nil } },
      { name: users[1].name, handle: users[1].handle, avatar_url: users[1].avatar_url,
        reputation: users[1].reload.formatted_reputation, links: { profile: nil } }
    ].map(&:to_obj)
    expected_users.each do |expected_user|
      assert_includes track.build_status.test_runner.volunteers.users, expected_user
    end
  end

  test "test_runner: health" do
    track = create :track, has_test_runner: false
    Track::UpdateBuildStatus.(track)
    assert_equal "missing", track.reload.build_status.test_runner.health

    track.update(has_test_runner: true, course: false)
    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.test_runner.health

    track.update(course: true)
    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 1 }
    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.test_runner.health

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 2 }
    Track::UpdateBuildStatus.(track)
    assert_equal "healthy", track.reload.build_status.test_runner.health

    create :submission_test_run, submission: (create :submission, track:), raw_results: { version: 3 }
    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.test_runner.health
  end

  test "representer" do
    track = create :track
    other_track = create :track, :random_slug

    20.times do
      submission = create :submission, track: track
      create :submission_representation, submission:
    end

    # 3 more submissions with matching ast_digest
    create_list(:submission_representation, 3, submission: Submission.last, ast_digest: Submission::Representation.last.ast_digest)

    create :exercise_representation, :with_feedback, source_submission: Submission.last,
      ast_digest: Submission::Representation.last.ast_digest
    create :exercise_representation, :with_feedback, source_submission: Submission.first,
      ast_digest: Submission::Representation.first.ast_digest

    # Sanity check: ignore representation without feedback
    create :exercise_representation, source_submission: Submission.first, ast_digest: Submission::Representation.first.ast_digest

    # Sanity check: ignore representation without feedback
    create :exercise_representation, source_submission: Submission.first, ast_digest: Submission::Representation.first.ast_digest

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
    submission = create :submission, track: track
    submission_representation = create :submission_representation, submission: submission
    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.representer.health

    create :exercise_representation, :with_feedback, source_submission: submission,
      ast_digest: submission_representation.ast_digest
    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.representer.health
  end

  test "representer: volunteers" do
    track = create :track, repo_url: 'https://github.com/exercism/ruby'
    other_track = create :track, :random_slug

    users = create_list(:user, 7)
    create :user_code_contribution_reputation_token, track: track, user: users[0], external_url: "#{track.representer_repo_url}/pull/1"
    create :user_code_contribution_reputation_token, track: track, user: users[1], external_url: "#{track.representer_repo_url}/pull/1"
    create :user_code_merge_reputation_token, track: track, user: users[2], external_url: "#{track.representer_repo_url}/pull/1"
    create :user_code_review_reputation_token, track: track, user: users[3], external_url: "#{track.representer_repo_url}/pull/2"
    create :user_code_review_reputation_token, track: track, user: users[4], external_url: "#{track.representer_repo_url}/pull/3"

    # Ignore tokens for track, analyzer and test runner repo
    create :user_code_merge_reputation_token, track: track, user: users[6], external_url: "#{track.repo_url}/pull/4"
    create :user_code_merge_reputation_token, track: track, user: users[6], external_url: "#{track.analyzer_repo_url}/pull/5"
    create :user_code_merge_reputation_token, track: track, user: users[6], external_url: "#{track.test_runner_repo_url}/pull/6"

    # Ignore other track
    create :user_code_merge_reputation_token, track: other_track, user: users[0], external_url: other_track.test_runner_repo_url

    Track::UpdateBuildStatus.(track)

    assert_equal 5, track.build_status.representer.volunteers.num_users
    assert_equal 3, track.build_status.representer.volunteers.users.size
    expected_users = [
      { name: users[0].name, handle: users[0].handle, avatar_url: users[0].avatar_url,
        reputation: users[0].reload.formatted_reputation, links: { profile: nil } },
      { name: users[1].name, handle: users[1].handle, avatar_url: users[1].avatar_url,
        reputation: users[1].reload.formatted_reputation, links: { profile: nil } }
    ].map(&:to_obj)
    expected_users.each do |expected_user|
      assert_includes track.build_status.representer.volunteers.users, expected_user
    end
  end

  test "analyzer" do
    track = create :track

    s_1 = create :submission, track: track
    create :submission_analysis, :with_comments, submission: s_1
    s_2 = create :submission, track: track
    create :submission_analysis, :with_comments, submission: s_2
    s_3 = create :submission, track: track
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

  test "analyzer: volunteers" do
    track = create :track, repo_url: 'https://github.com/exercism/ruby'
    other_track = create :track, :random_slug

    users = create_list(:user, 7)
    create :user_code_contribution_reputation_token, track: track, user: users[0], external_url: "#{track.analyzer_repo_url}/pull/1"
    create :user_code_contribution_reputation_token, track: track, user: users[1], external_url: "#{track.analyzer_repo_url}/pull/1"
    create :user_code_merge_reputation_token, track: track, user: users[2], external_url: "#{track.analyzer_repo_url}/pull/1"
    create :user_code_review_reputation_token, track: track, user: users[3], external_url: "#{track.analyzer_repo_url}/pull/2"
    create :user_code_review_reputation_token, track: track, user: users[4], external_url: "#{track.analyzer_repo_url}/pull/3"

    # Ignore tokens for track, representer and test runner repo
    create :user_code_merge_reputation_token, track: track, user: users[6], external_url: "#{track.repo_url}/pull/4"
    create :user_code_merge_reputation_token, track: track, user: users[6], external_url: "#{track.representer_repo_url}/pull/5"
    create :user_code_merge_reputation_token, track: track, user: users[6], external_url: "#{track.test_runner_repo_url}/pull/6"

    # Ignore other track
    create :user_code_merge_reputation_token, track: other_track, user: users[0], external_url: other_track.test_runner_repo_url

    Track::UpdateBuildStatus.(track)

    assert_equal 5, track.build_status.analyzer.volunteers.num_users
    assert_equal 3, track.build_status.analyzer.volunteers.users.size
    expected_users = [
      { name: users[0].name, handle: users[0].handle, avatar_url: users[0].avatar_url,
        reputation: users[0].reload.formatted_reputation, links: { profile: nil } },
      { name: users[1].name, handle: users[1].handle, avatar_url: users[1].avatar_url,
        reputation: users[1].reload.formatted_reputation, links: { profile: nil } }
    ].map(&:to_obj)
    expected_users.each do |expected_user|
      assert_includes track.build_status.analyzer.volunteers.users, expected_user
    end
  end

  test "analyzer: health" do
    track = create :track, has_analyzer: false
    Track::UpdateBuildStatus.(track)
    assert_equal "missing", track.reload.build_status.analyzer.health

    track.update(has_analyzer: true)
    create_list(:submission, 30, track:)
    Track::UpdateBuildStatus.(track)
    assert_equal "needs_attention", track.reload.build_status.analyzer.health

    submission = create :submission, track: track
    create :submission_analysis, :with_comments, submission: submission
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
    submission = create :submission, track: track
    create :submission_analysis, :with_comments, submission: submission

    # representer_health: :exemplar
    track.update(has_representer: true)
    submission_representation = create :submission_representation, submission: submission
    create :exercise_representation, :with_feedback, source_submission: submission, ast_digest: submission_representation.ast_digest

    # test_runner_health: :exemplar
    track.update(has_representer: true)
    create :submission_test_run, submission: submission, raw_results: { version: 3 }

    # practice_exercises_health: :exemplar
    track.update(course: false)
    create_list(:practice_exercise, 50, track:)

    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.health

    # syllabus_health: :exemplar
    track.update(course: true)
    create_list(:concept_exercise, 50, track:)

    Track::UpdateBuildStatus.(track)
    assert_equal "exemplar", track.reload.build_status.health

    # practice_exercises_health: :healthy
    PracticeExercise.limit(20).delete_all

    Track::UpdateBuildStatus.(track)
    assert_equal "healthy", track.reload.build_status.health
  end
end
