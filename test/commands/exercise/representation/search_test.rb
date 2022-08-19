require "test_helper"

class Exercise::Representation::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    representation_1 = create :exercise_representation, num_submissions: 3
    representation_2 = create :exercise_representation, num_submissions: 2

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.()
  end

  test "filter: criteria" do
    exercise_1 = create :practice_exercise, slug: 'anagram', title: 'Annie'
    exercise_2 = create :practice_exercise, slug: 'another', title: 'Another'
    exercise_3 = create :practice_exercise, slug: 'leap', title: 'Frog'
    representation_1 = create :exercise_representation, exercise: exercise_1, num_submissions: 3
    representation_2 = create :exercise_representation, exercise: exercise_2, num_submissions: 2
    representation_3 = create :exercise_representation, exercise: exercise_3, num_submissions: 1

    assert_equal [representation_1, representation_2, representation_3], Exercise::Representation::Search.(criteria: 'a')
    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(criteria: 'an')
    assert_equal [representation_3], Exercise::Representation::Search.(criteria: 'leap')
    assert_equal [representation_3], Exercise::Representation::Search.(criteria: 'frog')
  end

  test "filter: status" do
    representation_1 = create :exercise_representation, feedback_type: nil
    representation_2 = create :exercise_representation, feedback_type: :actionable, num_submissions: 3
    representation_3 = create :exercise_representation, feedback_type: :essential, num_submissions: 2

    assert_equal [representation_1], Exercise::Representation::Search.(status: :without_feedback)
    assert_equal [representation_2, representation_3], Exercise::Representation::Search.(status: :with_feedback)
  end

  test "filter: mentor when status is :without_feedback returns representations for mentored tracks" do
    track_1 = create :track, :random_slug
    track_2 = create :track, :random_slug
    track_3 = create :track, :random_slug
    mentor_1 = create :user
    mentor_2 = create :user
    mentor_3 = create :user

    create :user_track_mentorship, user: mentor_1, track: track_1
    create :user_track_mentorship, user: mentor_1, track: track_2
    create :user_track_mentorship, user: mentor_2, track: track_2
    create :user_track_mentorship, user: mentor_3, track: track_3

    representation_1 = create :exercise_representation, feedback_type: nil, num_submissions: 3,
      exercise: create(:practice_exercise, track: track_1)
    representation_2 = create :exercise_representation, feedback_type: nil, num_submissions: 2,
      exercise: create(:practice_exercise, track: track_2)
    representation_3 = create :exercise_representation, feedback_type: nil, num_submissions: 1,
      exercise: create(:practice_exercise, track: track_3)

    assert_equal [representation_1, representation_2],
      Exercise::Representation::Search.(mentor: mentor_1.reload, status: :without_feedback)
    assert_equal [representation_2], Exercise::Representation::Search.(mentor: mentor_2, status: :without_feedback)
    assert_equal [representation_3], Exercise::Representation::Search.(mentor: mentor_3, status: :without_feedback)
  end

  test "filter: mentor when status is :with_feedback returns representations where mentor is author or editor" do
    mentor_1 = create :user
    mentor_2 = create :user
    mentor_3 = create :user
    representation_1 = create :exercise_representation, feedback_type: :actionable, feedback_author: mentor_1, num_submissions: 3
    representation_2 = create :exercise_representation, feedback_type: :actionable, feedback_author: mentor_2,
      feedback_editor: mentor_1, num_submissions: 2
    representation_3 = create :exercise_representation, feedback_type: :actionable, feedback_editor: mentor_3, num_submissions: 1

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(mentor: mentor_1, status: :with_feedback)
    assert_equal [representation_2], Exercise::Representation::Search.(mentor: mentor_2, status: :with_feedback)
    assert_equal [representation_3], Exercise::Representation::Search.(mentor: mentor_3, status: :with_feedback)
  end

  test "filter: track" do
    track_1 = create :track, :random_slug
    track_2 = create :track, :random_slug
    exercise_1 = create :practice_exercise, track: track_1
    exercise_2 = create :practice_exercise, track: track_2
    representation_1 = create :exercise_representation, exercise: exercise_1, num_submissions: 3
    representation_2 = create :exercise_representation, exercise: exercise_1, num_submissions: 2
    representation_3 = create :exercise_representation, exercise: exercise_2, num_submissions: 1

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(track: track_1)
    assert_equal [representation_3], Exercise::Representation::Search.(track: track_2)
    assert_equal [representation_1, representation_2, representation_3], Exercise::Representation::Search.(track: [track_1, track_2])
  end

  test "paginates" do
    25.times { create :exercise_representation }

    first_page = Exercise::Representation::Search.()
    assert_equal 20, first_page.limit_value # Sanity
    assert_equal 20, first_page.length
    assert_equal 1, first_page.current_page
    assert_equal 25, first_page.total_count

    second_page = Exercise::Representation::Search.(page: 2)
    assert_equal 5, second_page.length
    assert_equal 2, second_page.current_page
    assert_equal 25, second_page.total_count

    page = Exercise::Representation::Search.(paginated: false)
    assert_equal 25, page.length
  end

  test "sorts" do
    representation_1 = create :exercise_representation, num_submissions: 2, last_submitted_at: Time.zone.now - 3.days
    representation_2 = create :exercise_representation, num_submissions: 1, last_submitted_at: Time.zone.now - 5.days
    representation_3 = create :exercise_representation, num_submissions: 8, last_submitted_at: Time.zone.now - 4.days

    # Default: order by num_submissions
    assert_equal [representation_3, representation_1, representation_2], Exercise::Representation::Search.()
    assert_equal [representation_3, representation_1, representation_2], Exercise::Representation::Search.(order: :most_submissions)
    assert_equal [representation_1, representation_3, representation_2], Exercise::Representation::Search.(order: :most_recent)
    assert_equal [representation_1, representation_2, representation_3], Exercise::Representation::Search.(sorted: false)
  end
end
