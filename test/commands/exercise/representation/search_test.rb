require "test_helper"

class Exercise::Representation::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    representation_1 = create :exercise_representation, num_submissions: 3
    representation_2 = create :exercise_representation, num_submissions: 2

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(with_feedback: false)
  end

  test "filter: criteria" do
    exercise_1 = create :practice_exercise, slug: 'anagram', title: 'Annie'
    exercise_2 = create :practice_exercise, slug: 'another', title: 'Another'
    exercise_3 = create :practice_exercise, slug: 'leap', title: 'Frog'
    representation_1 = create :exercise_representation, exercise: exercise_1, num_submissions: 3
    representation_2 = create :exercise_representation, exercise: exercise_2, num_submissions: 2
    representation_3 = create :exercise_representation, exercise: exercise_3, num_submissions: 1

    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(criteria: 'a', with_feedback: false)
    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(criteria: 'an', with_feedback: false)
    assert_equal [representation_3], Exercise::Representation::Search.(criteria: 'leap', with_feedback: false)
    assert_equal [representation_3], Exercise::Representation::Search.(criteria: 'frog', with_feedback: false)
  end

  test "filter: with_feedback" do
    representation_1 = create :exercise_representation, feedback_type: nil
    representation_2 = create :exercise_representation, feedback_type: :actionable, num_submissions: 3
    representation_3 = create :exercise_representation, feedback_type: :essential, num_submissions: 2

    assert_equal [representation_1], Exercise::Representation::Search.(with_feedback: false)
    assert_equal [representation_2, representation_3], Exercise::Representation::Search.(with_feedback: true)
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
      Exercise::Representation::Search.(mentor: mentor_1.reload, with_feedback: false)
    assert_equal [representation_2], Exercise::Representation::Search.(mentor: mentor_2, with_feedback: false)
    assert_equal [representation_3], Exercise::Representation::Search.(mentor: mentor_3, with_feedback: false)
  end

  test "filter: mentor when with_feedback is true returns representations where mentor is author or editor" do
    mentor_1 = create :user
    mentor_2 = create :user
    mentor_3 = create :user
    representation_1 = create :exercise_representation, feedback_type: :actionable, feedback_author: mentor_1, num_submissions: 3
    representation_2 = create :exercise_representation, feedback_type: :actionable, feedback_author: mentor_2,
      feedback_editor: mentor_1, num_submissions: 2
    representation_3 = create :exercise_representation, feedback_type: :actionable, feedback_editor: mentor_3, num_submissions: 1

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(mentor: mentor_1, with_feedback: true)
    assert_equal [representation_2], Exercise::Representation::Search.(mentor: mentor_2, with_feedback: true)
    assert_equal [representation_3], Exercise::Representation::Search.(mentor: mentor_3, with_feedback: true)
  end

  test "filter: track" do
    track_1 = create :track, :random_slug
    track_2 = create :track, :random_slug
    exercise_1 = create :practice_exercise, track: track_1
    exercise_2 = create :practice_exercise, track: track_2
    representation_1 = create :exercise_representation, exercise: exercise_1, num_submissions: 3
    representation_2 = create :exercise_representation, exercise: exercise_1, num_submissions: 2
    representation_3 = create :exercise_representation, exercise: exercise_2, num_submissions: 1

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(track: track_1, with_feedback: false)
    assert_equal [representation_3], Exercise::Representation::Search.(track: track_2, with_feedback: false)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(track: [track_1, track_2], with_feedback: false)
  end

  test "filter: only_mentored_solutions" do
    mentor_1 = create :user
    mentor_2 = create :user
    mentor_3 = create :user
    track_1 = create :track, :random_slug
    track_2 = create :track, :random_slug
    create :user_track_mentorship, user: mentor_1, track: track_1
    create :user_track_mentorship, user: mentor_1, track: track_2
    create :user_track_mentorship, user: mentor_2, track: track_2
    exercise_1 = create :practice_exercise, track: track_1
    exercise_2 = create :practice_exercise, track: track_2
    exercise_3 = create :practice_exercise, track: track_2
    solution_1 = create :practice_solution, exercise: exercise_1, track: track_1
    solution_2 = create :practice_solution, exercise: exercise_2, track: track_2
    solution_3 = create :practice_solution, exercise: exercise_3, track: track_2
    submission_1 = create :submission, solution: solution_1
    submission_2 = create :submission, solution: solution_2
    submission_3 = create :submission, solution: solution_3
    create :mentor_discussion, mentor: mentor_1, solution: solution_1
    create :mentor_discussion, mentor: mentor_1, solution: solution_3
    representation_1 = create :exercise_representation, feedback_type: nil, num_submissions: 3, source_submission: submission_1,
      exercise: exercise_1
    representation_2 = create :exercise_representation, feedback_type: nil, num_submissions: 2, source_submission: submission_2,
      exercise: exercise_2
    representation_3 = create :exercise_representation, feedback_type: nil, num_submissions: 1, source_submission: submission_3,
      exercise: exercise_3

    assert_equal [representation_1, representation_3],
      Exercise::Representation::Search.(mentor: mentor_1.reload, only_mentored_solutions: true, with_feedback: false)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(mentor: mentor_1.reload, only_mentored_solutions: false, with_feedback: false)
    assert_empty Exercise::Representation::Search.(mentor: mentor_2, only_mentored_solutions: true, with_feedback: false)
    assert_equal [representation_2, representation_3],
      Exercise::Representation::Search.(mentor: mentor_2, only_mentored_solutions: false, with_feedback: false)
    assert_empty Exercise::Representation::Search.(mentor: mentor_3, only_mentored_solutions: true, with_feedback: false)
    assert_empty Exercise::Representation::Search.(mentor: mentor_3, only_mentored_solutions: false, with_feedback: false)
  end

  test "paginates" do
    25.times { create :exercise_representation }

    first_page = Exercise::Representation::Search.(with_feedback: false)
    assert_equal 20, first_page.limit_value # Sanity
    assert_equal 20, first_page.length
    assert_equal 1, first_page.current_page
    assert_equal 25, first_page.total_count

    second_page = Exercise::Representation::Search.(page: 2, with_feedback: false)
    assert_equal 5, second_page.length
    assert_equal 2, second_page.current_page
    assert_equal 25, second_page.total_count

    page = Exercise::Representation::Search.(paginated: false, with_feedback: false)
    assert_equal 25, page.length
  end

  test "sorts" do
    representation_1 = create :exercise_representation, num_submissions: 2, last_submitted_at: Time.zone.now - 3.days
    representation_2 = create :exercise_representation, num_submissions: 1, last_submitted_at: Time.zone.now - 5.days
    representation_3 = create :exercise_representation, num_submissions: 8, last_submitted_at: Time.zone.now - 4.days

    # Default: order by num_submissions
    assert_equal [representation_3, representation_1, representation_2], Exercise::Representation::Search.(with_feedback: false)
    assert_equal [representation_3, representation_1, representation_2],
      Exercise::Representation::Search.(order: :most_submissions, with_feedback: false)
    assert_equal [representation_1, representation_3, representation_2],
      Exercise::Representation::Search.(order: :most_recent, with_feedback: false)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(sorted: false, with_feedback: false)
  end
end
