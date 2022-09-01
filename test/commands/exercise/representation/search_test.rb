require "test_helper"

class Exercise::Representation::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    mentor = create :user
    representation_1 = create :exercise_representation, num_submissions: 3
    representation_2 = create :exercise_representation, num_submissions: 2

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(with_feedback: false, mentor:)
  end

  test "filter: criteria" do
    mentor = create :user
    exercise_1 = create :practice_exercise, slug: 'anagram', title: 'Annie'
    exercise_2 = create :practice_exercise, slug: 'another', title: 'Another'
    exercise_3 = create :practice_exercise, slug: 'leap', title: 'Frog'
    representation_1 = create :exercise_representation, exercise: exercise_1, num_submissions: 3
    representation_2 = create :exercise_representation, exercise: exercise_2, num_submissions: 2
    representation_3 = create :exercise_representation, exercise: exercise_3, num_submissions: 1

    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(criteria: 'a', with_feedback: false, mentor:)
    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(criteria: 'an', with_feedback: false, mentor:)
    assert_equal [representation_3], Exercise::Representation::Search.(criteria: 'leap', with_feedback: false, mentor:)
    assert_equal [representation_3], Exercise::Representation::Search.(criteria: 'frog', with_feedback: false, mentor:)
  end

  test "filter: with_feedback" do
    mentor = create :user
    representation_1 = create :exercise_representation, feedback_author: nil, feedback_type: nil, num_submissions: 3
    representation_2 = create :exercise_representation, feedback_author: mentor, feedback_type: :actionable, num_submissions: 2
    representation_3 = create :exercise_representation, feedback_author: mentor, feedback_type: :essential, num_submissions: 1

    assert_equal [representation_1], Exercise::Representation::Search.(with_feedback: false, mentor:)
    assert_equal [representation_2, representation_3], Exercise::Representation::Search.(with_feedback: true, mentor:)
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

    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(mentor: mentor_1.reload, with_feedback: false)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(mentor: mentor_2, with_feedback: false)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(mentor: mentor_3, with_feedback: false)
  end

  test "filter: mentor when with_feedback is true returns representations where mentor is author or editor" do
    mentor_1 = create :user
    mentor_2 = create :user
    mentor_3 = create :user
    representation_1 = create :exercise_representation, feedback_type: :actionable, feedback_author: mentor_1, num_submissions: 3
    representation_2 = create :exercise_representation, feedback_type: :actionable, feedback_author: mentor_1, num_submissions: 2
    representation_3 = create :exercise_representation, feedback_type: :actionable, feedback_author: mentor_2, num_submissions: 1

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(mentor: mentor_1, with_feedback: true)
    assert_equal [representation_3], Exercise::Representation::Search.(mentor: mentor_2, with_feedback: true)
    assert_empty Exercise::Representation::Search.(mentor: mentor_3, with_feedback: true)
  end

  test "filter: track" do
    mentor = create :user
    track_1 = create :track, :random_slug
    track_2 = create :track, :random_slug
    exercise_1 = create :practice_exercise, track: track_1
    exercise_2 = create :practice_exercise, track: track_2
    representation_1 = create :exercise_representation, exercise: exercise_1, num_submissions: 3
    representation_2 = create :exercise_representation, exercise: exercise_1, num_submissions: 2
    representation_3 = create :exercise_representation, exercise: exercise_2, num_submissions: 1

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(track: track_1, with_feedback: false, mentor:)
    assert_equal [representation_3], Exercise::Representation::Search.(track: track_2, with_feedback: false, mentor:)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(track: [track_1, track_2], with_feedback: false, mentor:)
  end

  test "filter: only_mentored_solutions" do
    mentor_1 = create :user
    mentor_2 = create :user
    mentor_3 = create :user
    representation_1 = create :exercise_representation, feedback_author: mentor_1, feedback_type: :actionable, num_submissions: 3,
      ast_digest: 'digest_1'
    representation_2 = create :exercise_representation, feedback_author: mentor_2, feedback_type: :actionable, num_submissions: 2,
      ast_digest: 'digest_2'
    representation_3 = create :exercise_representation, feedback_author: mentor_1, feedback_type: :actionable, num_submissions: 1,
      ast_digest: 'digest_3'
    create :submission_representation, ast_digest: representation_1.ast_digest, mentored_by: mentor_1
    create :submission_representation, ast_digest: representation_2.ast_digest
    create :submission_representation, ast_digest: representation_3.ast_digest

    assert_equal [representation_1],
      Exercise::Representation::Search.(mentor: mentor_1.reload, only_mentored_solutions: true, with_feedback: true)
    assert_equal [representation_1, representation_3],
      Exercise::Representation::Search.(mentor: mentor_1.reload, only_mentored_solutions: false, with_feedback: true)
    assert_empty Exercise::Representation::Search.(mentor: mentor_2, only_mentored_solutions: true, with_feedback: true)
    assert_equal [representation_2],
      Exercise::Representation::Search.(mentor: mentor_2, only_mentored_solutions: false, with_feedback: true)
    assert_empty Exercise::Representation::Search.(mentor: mentor_3, only_mentored_solutions: true, with_feedback: true)
    assert_empty Exercise::Representation::Search.(mentor: mentor_3, only_mentored_solutions: false, with_feedback: true)
  end

  test "paginates" do
    mentor = create :user
    25.times { create :exercise_representation }

    first_page = Exercise::Representation::Search.(with_feedback: false, mentor:)
    assert_equal 20, first_page.limit_value # Sanity
    assert_equal 20, first_page.length
    assert_equal 1, first_page.current_page
    assert_equal 25, first_page.total_count

    second_page = Exercise::Representation::Search.(page: 2, with_feedback: false, mentor:)
    assert_equal 5, second_page.length
    assert_equal 2, second_page.current_page
    assert_equal 25, second_page.total_count

    page = Exercise::Representation::Search.(paginated: false, with_feedback: false, mentor:)
    assert_equal 25, page.length
  end

  test "sorts" do
    mentor = create :user
    representation_1 = create :exercise_representation, num_submissions: 2, last_submitted_at: Time.zone.now - 3.days
    representation_2 = create :exercise_representation, num_submissions: 1, last_submitted_at: Time.zone.now - 5.days
    representation_3 = create :exercise_representation, num_submissions: 8, last_submitted_at: Time.zone.now - 4.days

    # Default: order by num_submissions
    assert_equal [representation_3, representation_1, representation_2],
      Exercise::Representation::Search.(with_feedback: false, mentor:)
    assert_equal [representation_3, representation_1, representation_2],
      Exercise::Representation::Search.(order: :most_submissions, with_feedback: false, mentor:)
    assert_equal [representation_1, representation_3, representation_2],
      Exercise::Representation::Search.(order: :most_recent, with_feedback: false, mentor:)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(sorted: false, with_feedback: false, mentor:).order(:id)
  end
end
