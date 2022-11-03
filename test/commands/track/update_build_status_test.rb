require "test_helper"

class Track::UpdateBuildStatusTest < ActiveSupport::TestCase
  test "creates entry if key does not exists" do
    track = create :track

    # Sanity check
    assert_nil track.build_status

    Track::UpdateBuildStatus.(track)

    refute_nil track.reload.build_status
  end

  test "updates entry if key exists" do
    track = create :track
    Track::UpdateBuildStatus.(track)

    # Sanity check
    assert_equal 0, track.reload.build_status.dig(:students, :num_students)

    track.update(num_students: 33)
    Track::UpdateBuildStatus.(track)

    assert_equal 33, track.reload.build_status.dig(:students, :num_students)
  end

  test "students" do
    track = create :track

    create_list(:user_track, 20, track:, created_at: Time.current - 2.months)
    create_list(:user_track, 40, track:, created_at: Time.current - 29.days)
    create_list(:user_track, 30, track:, created_at: Time.current - 5.days)
    create_list(:user_track, 30, track: (create :track, :random_slug), created_at: Time.current - 5.days)

    Track::UpdateBuildStatus.(track)

    expected = { num_students: 90, num_students_per_day: 3 }
    assert_equal expected, track.build_status[:students]
  end

  test "submissions" do
    track = create :track

    create_list(:submission, 20, track:, created_at: Time.current - 2.months)
    create_list(:submission, 25, track:, created_at: Time.current - 29.days)
    create_list(:submission, 40, track:, created_at: Time.current - 5.days)
    create_list(:submission, 35, track: (create :track, :random_slug), created_at: Time.current - 5.days)

    Track::UpdateBuildStatus.(track)

    expected = { num_submissions: 85, num_submissions_per_day: 3 }
    assert_equal expected, track.build_status[:submissions]
  end

  test "mentor_discussions" do
    track = create :track
    create_list(:mentor_discussion, 16, track:)

    Track::UpdateBuildStatus.(track)

    expected = { num_discussions: 16 }
    assert_equal expected, track.build_status[:mentor_discussions]
  end

  test "volunteers" do
    track = create :track

    user_1 = create :user, reputation: 10
    user_2 = create :user, reputation: 14
    user_3 = create :user, reputation: 12
    user_4 = create :user, reputation: 13
    user_5 = create :user, reputation: 11
    user_6 = create :user, reputation: 10
    create :user_reputation_period, track_id: track.id, user: user_1, about: :track, category: :any
    create :user_reputation_period, track_id: track.id, user: user_1, about: :track, category: :building
    create :user_reputation_period, track_id: track.id, user: user_2, about: :track, category: :building
    create :user_reputation_period, track_id: track.id, user: user_3, about: :track, category: :maintaining
    create :user_reputation_period, track_id: track.id, user: user_3, about: :track, category: :authoring
    create :user_reputation_period, track_id: track.id, user: user_4, about: :track, category: :authoring
    create :user_reputation_period, track_id: track.id, user: user_5, about: :track, category: :mentoring
    create :user_reputation_period, user: user_6 # Ignore: no track

    Track::UpdateBuildStatus.(track)

    expected = {
      num_volunteers: 5,
      users: [
        { name: user_2.name, handle: user_2.handle, avatar_url: user_2.avatar_url, links: { profile: nil } },
        { name: user_4.name, handle: user_4.handle, avatar_url: user_4.avatar_url, links: { profile: nil } },
        { name: user_3.name, handle: user_3.handle, avatar_url: user_3.avatar_url, links: { profile: nil } },
        { name: user_5.name, handle: user_5.handle, avatar_url: user_5.avatar_url, links: { profile: nil } },
        { name: user_1.name, handle: user_1.handle, avatar_url: user_1.avatar_url, links: { profile: nil } }
      ]
    }
    assert_equal expected, track.build_status[:volunteers]
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
      { name: users[0].name, handle: users[0].handle, avatar_url: users[0].avatar_url, links: { profile: nil } },
      { name: users[1].name, handle: users[1].handle, avatar_url: users[1].avatar_url, links: { profile: nil } },
      { name: users[3].name, handle: users[3].handle, avatar_url: users[3].avatar_url, links: { profile: nil } }
    ]
    actual = track.build_status.dig(:syllabus, :volunteers)
    assert_equal 3, actual[:num_authors]
    assert_equal 2, actual[:num_contributors]
    assert_equal 3, actual[:users].size
    expected_users.each do |expected_user|
      assert_includes actual[:users], expected_user
    end
  end

  test "syllabus: concepts" do
    track = create :track, num_concepts: 5

    concepts = create_list(:concept, 7, track:)

    ce_1 = create :concept_exercise, track: track, status: :wip # Ignore wip
    ce_1.taught_concepts << concepts[0] # Ignore for wip exercise
    ce_2 = create :concept_exercise, track: track, status: :beta
    ce_2.taught_concepts << concepts[1]
    ce_3 = create :concept_exercise, track: track, status: :active
    ce_3.taught_concepts << concepts[2]
    ce_3.prerequisites << concepts[5] # Ignore concept if not taught
    ce_4 = create :concept_exercise, track: track, status: :deprecated # Ignore deprecated
    ce_4.taught_concepts << concepts[6] # Ignore for deprecated exercise

    users = create_list(:user, 5)
    create :concept_solution, exercise: ce_2, user: users[0], status: :started
    create :concept_solution, exercise: ce_2, user: users[1], status: :iterated
    create :concept_solution, :completed, exercise: ce_2, user: users[2]
    create :concept_solution, :published, exercise: ce_2, user: users[3]
    create :concept_solution, :published, exercise: ce_2, user: users[4]

    create :concept_solution, exercise: ce_3, user: users[0], status: :started
    create :concept_solution, :completed, exercise: ce_3, user: users[2]

    Track::UpdateBuildStatus.(track)

    expected = {
      num_concepts: 2,
      num_concepts_target: 2,
      created: [
        { slug: concepts[1].slug, name: concepts[1].name, num_students_learnt: 3 },
        { slug: concepts[2].slug, name: concepts[2].name, num_students_learnt: 1 }
      ]
    }
    assert_equal expected, track.build_status.dig(:syllabus, :concepts)
  end

  test "syllabus: concept_exercises" do
    track = create :track, num_concepts: 5

    concepts = create_list(:concept, 7, track:)

    ce_1 = create :concept_exercise, track: track, status: :wip # Ignore wip
    ce_1.taught_concepts << concepts[0] # Ignore for wip exercise
    ce_2 = create :concept_exercise, track: track, status: :beta, slug: 'lasagna'
    ce_2.taught_concepts << concepts[1]
    ce_3 = create :concept_exercise, track: track, status: :active, slug: 'sweethearts'
    ce_3.taught_concepts << concepts[2]
    ce_3.prerequisites << concepts[5] # Ignore concept if not taught
    ce_4 = create :concept_exercise, track: track, status: :deprecated # Ignore deprecated
    ce_4.taught_concepts << concepts[6] # Ignore for deprecated exercise

    users = create_list(:user, 5)
    create :concept_solution, exercise: ce_2, user: users[0], status: :started
    s_2 = create :concept_solution, exercise: ce_2, user: users[1], status: :iterated
    create :submission, exercise: ce_2, user: users[1], solution: s_2
    s_3 = create :concept_solution, :completed, exercise: ce_2, user: users[2]
    create :submission, exercise: ce_2, user: users[2], solution: s_3
    s_4 = create :concept_solution, :published, exercise: ce_2, user: users[3]
    create :submission, exercise: ce_2, user: users[3], solution: s_4
    s_5 = create :concept_solution, :published, exercise: ce_2, user: users[4]
    create :submission, exercise: ce_2, user: users[4], solution: s_5
    s_6 = create :concept_solution, exercise: ce_3, user: users[0], status: :started
    create :submission, exercise: ce_3, user: users[0], solution: s_6
    s_7 = create :concept_solution, :completed, exercise: ce_3, user: users[2]
    create :submission, exercise: ce_3, user: users[2], solution: s_7

    Track::UpdateBuildStatus.(track)

    expected = {
      num_exercises: 2,
      num_exercises_target: 2,
      created: [
        {
          slug: ce_2.slug,
          title: ce_2.title,
          icon_url: ce_2.icon_url,
          num_started: 5,
          num_submitted: 4,
          num_completed: 3,
          links: { self: "/tracks/ruby/exercises/#{ce_2.slug}" }
        },
        {
          slug: ce_3.slug,
          title: ce_3.title,
          icon_url: ce_3.icon_url,
          num_started: 2,
          num_submitted: 2,
          num_completed: 1,
          links: { self: "/tracks/ruby/exercises/#{ce_3.slug}" }
        }
      ]
    }
    assert_equal expected, track.build_status.dig(:syllabus, :concept_exercises)
  end

  test "practice_exercises" do
    track = create :track, num_concepts: 5

    create :practice_exercise, track: track, status: :wip # Ignore wip
    pe_2 = create :practice_exercise, track: track, status: :beta, slug: 'leap'
    pe_3 = create :practice_exercise, track: track, status: :active, slug: 'anagram'
    create :practice_exercise, track: track, status: :deprecated # Ignore deprecated

    users = create_list(:user, 5)
    create :practice_solution, exercise: pe_2, user: users[0], status: :started
    s_2 = create :practice_solution, exercise: pe_2, user: users[1], status: :iterated
    create :submission, exercise: pe_2, user: users[1], solution: s_2
    s_3 = create :practice_solution, :completed, exercise: pe_2, user: users[2]
    create :submission, exercise: pe_2, user: users[2], solution: s_3
    s_4 = create :practice_solution, :published, exercise: pe_2, user: users[3]
    create :submission, exercise: pe_2, user: users[3], solution: s_4
    s_5 = create :practice_solution, :published, exercise: pe_2, user: users[4]
    create :submission, exercise: pe_2, user: users[4], solution: s_5
    s_6 = create :practice_solution, exercise: pe_3, user: users[0], status: :started
    create :submission, exercise: pe_3, user: users[0], solution: s_6
    s_7 = create :practice_solution, :completed, exercise: pe_3, user: users[2]
    create :submission, exercise: pe_3, user: users[2], solution: s_7

    Track::UpdateBuildStatus.(track)

    expected = {
      num_exercises: 2,
      num_exercises_target: 2,
      created: [
        {
          slug: pe_3.slug,
          title: pe_3.title,
          icon_url: pe_3.icon_url,
          num_started: 2,
          num_submitted: 2,
          num_completed: 1,
          links: { self: "/tracks/ruby/exercises/#{pe_3.slug}" }
        },
        {
          slug: pe_2.slug,
          title: pe_2.title,
          icon_url: pe_2.icon_url,
          num_started: 5,
          num_submitted: 4,
          num_completed: 3,
          links: { self: "/tracks/ruby/exercises/#{pe_2.slug}" }
        }
      ]
    }
    assert_equal expected, track.build_status[:practice_exercises]
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

    expected = {
      num_test_runs: 36,
      num_passed: 5,
      num_failed: 7,
      num_errored: 24,
      num_passed_percentage: 14,
      num_failed_percentage: 19,
      num_errored_percentage: 67
    }
    assert_equal expected, track.build_status[:test_runner].except(:volunteers)
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

    expected_users = [
      { name: users[0].name, handle: users[0].handle, avatar_url: users[0].avatar_url, links: { profile: nil } },
      { name: users[1].name, handle: users[1].handle, avatar_url: users[1].avatar_url, links: { profile: nil } }
    ]
    actual = track.build_status.dig(:test_runner, :volunteers)
    assert_equal 2, actual[:num_authors]
    assert_equal 3, actual[:num_contributors]
    assert_equal 3, actual[:users].size
    expected_users.each do |expected_user|
      assert_includes actual[:users], expected_user
    end
  end

  test "representer" do
    track = create :track

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

    Track::UpdateBuildStatus.(track)

    expected = {
      num_representations: 23,
      num_comments_made: 5,
      display_rate_percentage: 25
    }
    assert_equal expected, track.build_status[:representer].except(:volunteers)
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

    expected_users = [
      { name: users[0].name, handle: users[0].handle, avatar_url: users[0].avatar_url, links: { profile: nil } },
      { name: users[1].name, handle: users[1].handle, avatar_url: users[1].avatar_url, links: { profile: nil } }
    ]
    actual = track.build_status.dig(:representer, :volunteers)
    assert_equal 2, actual[:num_authors]
    assert_equal 3, actual[:num_contributors]
    assert_equal 3, actual[:users].size
    expected_users.each do |expected_user|
      assert_includes actual[:users], expected_user
    end
  end

  test "analyzer" do
    track = create :track

    s_1 = create :submission, track: track
    create :submission_analysis, submission: s_1, data: { status: :pass, comments: %w[comment_1] }
    s_2 = create :submission, track: track
    create :submission_analysis, submission: s_2, data: { status: :pass, comments: %w[comment_1 comment_2] }
    create_list(:submission, 3, track:)
    create_list(:submission, 4, track: create(:track, :random_slug))
    s_3 = create :submission, track: create(:track, :random_slug)
    create :submission_analysis, submission: s_3, data: { status: :pass, comments: %w[comment_1 comment_2 comment_3 comment_4] }

    Track::UpdateBuildStatus.(track)

    expected = {
      num_comments: 3,
      display_rate_percentage: 40
    }
    assert_equal expected, track.build_status[:analyzer].except(:volunteers)
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

    expected_users = [
      { name: users[0].name, handle: users[0].handle, avatar_url: users[0].avatar_url, links: { profile: nil } },
      { name: users[1].name, handle: users[1].handle, avatar_url: users[1].avatar_url, links: { profile: nil } }
    ]
    actual = track.build_status.dig(:analyzer, :volunteers)
    assert_equal 2, actual[:num_authors]
    assert_equal 3, actual[:num_contributors]
    assert_equal 3, actual[:users].size
    expected_users.each do |expected_user|
      assert_includes actual[:users], expected_user
    end
  end
end
