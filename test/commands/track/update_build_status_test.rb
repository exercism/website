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

  test "concepts" do
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

    Track::UpdateBuildStatus.(track)

    redis_value = JSON.parse(redis.get(track.build_status_key), symbolize_names: true)
    expected = {
      num_concepts: 2,
      num_concepts_target: 2,
      created: [
        { slug: concepts[1].slug, name: concepts[1].name },
        { slug: concepts[2].slug, name: concepts[2].name }
      ]
    }
    assert_equal expected, redis_value[:concepts]
  end
end
