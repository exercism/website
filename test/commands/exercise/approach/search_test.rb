require "test_helper"

class Exercise::Approach::SearchTest < ActiveSupport::TestCase
  test "no options returns all approaches, ordered by newest first" do
    approach_1 = create :exercise_approach, :random, updated_at: 2.weeks.ago
    approach_2 = create :exercise_approach, :random, updated_at: 4.weeks.ago
    approach_3 = create :exercise_approach, :random, updated_at: 1.week.ago

    assert_equal [approach_3, approach_1, approach_2], Exercise::Approach::Search.()
  end

  test "filter: track" do
    track_1 = create :track, slug: 'fsharp'
    track_2 = create :track, slug: 'ruby'

    approach_1 = create :exercise_approach, :random, updated_at: 4.weeks.ago, track: track_1
    approach_2 = create :exercise_approach, :random, updated_at: 1.week.ago, track: track_1

    # Add non-matching approaches to ensure they are not counted
    create :exercise_approach, :random, track: track_2
    create :exercise_approach, :random, track: track_2

    assert_equal [approach_2, approach_1], Exercise::Approach::Search.(track_slug: track_1.slug)
  end

  test "filter: exercise" do
    track_1 = create :track, slug: 'fsharp'
    track_2 = create :track, slug: 'ruby'
    exercise = create :practice_exercise, slug: 'anagram', track: track_1

    approach_1 = create(:exercise_approach, :random, updated_at: 4.weeks.ago, track: track_1, exercise:)
    approach_2 = create(:exercise_approach, :random, updated_at: 1.week.ago, track: track_1, exercise:)

    # Add non-matching approaches to ensure they are not counted
    create :exercise_approach, :random, track: track_2, exercise: create(:practice_exercise, slug: 'leap', track: track_2)
    create :exercise_approach, :random, track: track_2, exercise: create(:practice_exercise, slug: 'bob', track: track_2)

    assert_equal [approach_2, approach_1], Exercise::Approach::Search.(exercise_slug: exercise.slug)
  end

  test "ordering" do
    approach_1 = create :exercise_approach, :random, updated_at: 2.weeks.ago, track: (create :track, slug: 'fsharp')
    approach_2 = create :exercise_approach, :random, updated_at: 4.weeks.ago, track: (create :track, slug: 'csharp')
    approach_3 = create :exercise_approach, :random, updated_at: 1.week.ago, track: (create :track, slug: 'd')

    assert_equal [approach_3, approach_1, approach_2], Exercise::Approach::Search.(order: "newest")
    assert_equal [approach_2, approach_1, approach_3], Exercise::Approach::Search.(order: "oldest")
    assert_equal [approach_2, approach_3, approach_1], Exercise::Approach::Search.(order: "track")
  end

  test "pagination" do
    25.times { create :exercise_approach, :random }

    first_page = Exercise::Approach::Search.()
    assert_equal 20, first_page.limit_value # Sanity

    assert_equal 20, first_page.length
    assert_equal 1, first_page.current_page
    assert_equal 25, first_page.total_count

    second_page = Exercise::Approach::Search.(page: 2)
    assert_equal 5, second_page.length
    assert_equal 2, second_page.current_page
    assert_equal 25, second_page.total_count
  end
end
