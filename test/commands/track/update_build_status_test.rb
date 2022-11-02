require "test_helper"

class Track::UpdateBuildStatusTest < ActiveSupport::TestCase
  test "creates entry if key does not exists" do
    redis = Exercism.redis_tooling_client
    track = create :track

    # Sanity check
    assert 0, redis.exists(track.build_status_key)

    Track::UpdateBuildStatus.(track)

    assert 1, redis.exists(track.build_status_key)
  end

  test "updates entry if key exists" do
    redis = Exercism.redis_tooling_client
    track = create :track
    Track::UpdateBuildStatus.(track)

    # Sanity check
    redis_value = JSON.parse(redis.get(track.build_status_key), symbolize_names: true)
    assert_equal 0, redis_value.dig(:students, :num_students)

    track.update(num_students: 33)
    Track::UpdateBuildStatus.(track)

    redis_value = JSON.parse(redis.get(track.build_status_key), symbolize_names: true)
    assert_equal 33, redis_value.dig(:students, :num_students)
  end

  test "students" do
    redis = Exercism.redis_tooling_client
    track = create :track

    create_list(:user_track, 20, track:, created_at: Time.current - 2.months)
    create_list(:user_track, 40, track:, created_at: Time.current - 29.days)
    create_list(:user_track, 30, track:, created_at: Time.current - 5.days)
    create_list(:user_track, 30, track: (create :track, :random_slug), created_at: Time.current - 5.days)

    Track::UpdateBuildStatus.(track)

    redis_value = JSON.parse(redis.get(track.build_status_key), symbolize_names: true)
    expected = { num_students: 90, num_students_per_day: 3 }
    assert_equal expected, redis_value[:students]
  end

  test "submissions" do
    redis = Exercism.redis_tooling_client
    track = create :track

    create_list(:submission, 20, track:, created_at: Time.current - 2.months)
    create_list(:submission, 25, track:, created_at: Time.current - 29.days)
    create_list(:submission, 40, track:, created_at: Time.current - 5.days)
    create_list(:submission, 35, track: (create :track, :random_slug), created_at: Time.current - 5.days)

    Track::UpdateBuildStatus.(track)

    redis_value = JSON.parse(redis.get(track.build_status_key), symbolize_names: true)
    expected = { num_submissions: 85, num_submissions_per_day: 3 }
    assert_equal expected, redis_value[:submissions]
  end

  test "mentor_discussions" do
    redis = Exercism.redis_tooling_client
    track = create :track

    create_list(:mentor_discussion, 16, track:)

    Track::UpdateBuildStatus.(track)

    redis_value = JSON.parse(redis.get(track.build_status_key), symbolize_names: true)
    expected = { num_discussions: 16 }
    assert_equal expected, redis_value[:mentor_discussions]
  end

  test "syllabus: concepts" do
    redis = Exercism.redis_tooling_client
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

    redis_value = JSON.parse(redis.get(track.build_status_key), symbolize_names: true)
    expected = {
      num_concepts: 2,
      num_concepts_target: 2,
      created: [
        { slug: concepts[1].slug, name: concepts[1].name, num_students_learnt: 3 },
        { slug: concepts[2].slug, name: concepts[2].name, num_students_learnt: 1 }
      ]
    }
    assert_equal expected, redis_value.dig(:syllabus, :concepts)
  end

  test "syllabus: concept_exercises" do
    redis = Exercism.redis_tooling_client
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

    redis_value = JSON.parse(redis.get(track.build_status_key), symbolize_names: true)
    expected = {
      num_exercises: 2,
      num_exercises_target: 2,
      created: [
        {
          slug: ce_2.slug,
          title: ce_2.title,
          icon_url: ce_2.icon_url,
          stats: { num_started: 5, num_submitted: 4, num_completed: 3 },
          links: { self: "/tracks/ruby/exercises/#{ce_2.slug}" }
        },
        {
          slug: ce_3.slug,
          title: ce_3.title,
          icon_url: ce_3.icon_url,
          stats: { num_started: 2, num_submitted: 2, num_completed: 1 },
          links: { self: "/tracks/ruby/exercises/#{ce_3.slug}" }
        }
      ]
    }
    assert_equal expected, redis_value.dig(:syllabus, :concept_exercises)
  end

  test "practice_exercises" do
    redis = Exercism.redis_tooling_client
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

    redis_value = JSON.parse(redis.get(track.build_status_key), symbolize_names: true)
    expected = {
      num_exercises: 2,
      num_exercises_target: 2,
      created: [
        {
          slug: pe_3.slug,
          title: pe_3.title,
          icon_url: pe_3.icon_url,
          stats: { num_started: 2, num_submitted: 2, num_completed: 1 },
          links: { self: "/tracks/ruby/exercises/#{pe_3.slug}" }
        },
        {
          slug: pe_2.slug,
          title: pe_2.title,
          icon_url: pe_2.icon_url,
          stats: { num_started: 5, num_submitted: 4, num_completed: 3 },
          links: { self: "/tracks/ruby/exercises/#{pe_2.slug}" }
        }
      ]
    }
    assert_equal expected, redis_value[:practice_exercises]
  end
end
