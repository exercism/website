require "test_helper"

class Exercise::Representation::SearchTest < ActiveSupport::TestCase
  test "by default it returns feedback with > 1 submission" do
    track = create :track
    mentor = create :user
    representation_1 = create(:exercise_representation, num_submissions: 3, track:)
    representation_2 = create(:exercise_representation, num_submissions: 2, track:)
    create(:exercise_representation, num_submissions: 1, track:)
    create(:exercise_representation, num_submissions: 0, track:)

    assert_equal [representation_1, representation_2],
      Exercise::Representation::Search.(mode: :without_feedback, representer_version: 1, mentor:, track:)
  end

  test "it returns correct representer version" do
    track = create :track
    mentor = create :user
    create(:exercise_representation, track:, representer_version: 1, num_submissions: 5)
    representation = create(:exercise_representation, track:, representer_version: 2, num_submissions: 5)
    create(:exercise_representation, track:, representer_version: 1, num_submissions: 5)

    assert_equal [representation], Exercise::Representation::Search.(mode: :without_feedback, representer_version: 2, mentor:, track:)
  end

  test "filter: criteria" do
    track = create :track
    mentor = create :user
    exercise_1 = create :practice_exercise, slug: 'anagram', title: 'Annie'
    exercise_2 = create :practice_exercise, slug: 'isogram', title: 'Isogram'
    exercise_3 = create :practice_exercise, slug: 'leap', title: 'Frog'
    representation_1 = create(:exercise_representation, exercise: exercise_1, num_submissions: 4, track:)
    representation_2 = create(:exercise_representation, exercise: exercise_2, num_submissions: 3, track:)
    representation_3 = create(:exercise_representation, exercise: exercise_3, num_submissions: 2, track:)

    assert_equal [representation_1, representation_2],
      Exercise::Representation::Search.(criteria: 'gram', mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_1],
      Exercise::Representation::Search.(criteria: 'agram', mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_3],
      Exercise::Representation::Search.(criteria: 'leap', mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_3],
      Exercise::Representation::Search.(criteria: 'fro', mode: :without_feedback, representer_version: 1, mentor:, track:)
  end

  test "filter: criteria does not filter if < 3 characters long (when trimmed)" do
    track = create :track
    mentor = create :user
    exercise_1 = create :practice_exercise, slug: 'anagram', title: 'Annie'
    exercise_2 = create :practice_exercise, slug: 'another', title: 'Another'
    exercise_3 = create :practice_exercise, slug: 'leap', title: 'Frog'
    representation_1 = create(:exercise_representation, exercise: exercise_1, num_submissions: 4, track:)
    representation_2 = create(:exercise_representation, exercise: exercise_2, num_submissions: 3, track:)
    representation_3 = create(:exercise_representation, exercise: exercise_3, num_submissions: 2, track:)

    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(criteria: nil, mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(criteria: '', mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(criteria: 'p', mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(criteria: '  p  ', mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(criteria: 'an', mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_3],
      Exercise::Representation::Search.(criteria: 'lea', mode: :without_feedback, representer_version: 1, mentor:, track:)
  end

  test "filter: criteria and track" do
    mentor = create :user
    ruby = create :track, slug: :ruby
    javascript = create :track, slug: :javascript
    ruby_anagram = create :practice_exercise, slug: 'anagram', title: 'Anagram Ruby', track: ruby
    js_anagram = create :practice_exercise, slug: 'anagram', title: 'Anagram JS', track: javascript
    ruby_representation = create :exercise_representation, exercise: ruby_anagram, num_submissions: 3, track: ruby
    js_representation = create :exercise_representation, exercise: js_anagram, num_submissions: 3, track: javascript

    assert_equal [ruby_representation, js_representation],
      Exercise::Representation::Search.(track: [ruby, javascript], criteria: 'anagram', mode: :without_feedback,
        representer_version: 1, mentor:)
    assert_equal [ruby_representation],
      Exercise::Representation::Search.(track: ruby, criteria: 'anagram', mode: :without_feedback, representer_version: 1, mentor:)
    assert_equal [js_representation],
      Exercise::Representation::Search.(track: javascript, criteria: 'anagram', mode: :without_feedback, representer_version: 1,
        mentor:)
  end

  test "filter: with_feedback" do
    track = create :track
    mentor = create :user
    other_mentor = create :user
    representation_1 = create(:exercise_representation, feedback_author: nil, feedback_type: nil, num_submissions: 5, track:)
    representation_2 = create(:exercise_representation, feedback_author: mentor, feedback_type: :actionable, num_submissions: 4,
      track:)
    representation_3 = create(:exercise_representation, feedback_author: mentor, feedback_type: :essential, num_submissions: 3,
      track:)
    representation_4 = create(:exercise_representation, feedback_author: other_mentor, feedback_type: :essential, num_submissions: 2,
      track:)

    assert_equal [representation_1],
      Exercise::Representation::Search.(mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_1],
      Exercise::Representation::Search.(mode: :without_feedback, representer_version: 1, mentor: nil, track:)

    assert_equal [representation_2, representation_3],
      Exercise::Representation::Search.(mode: :with_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_2, representation_3, representation_4],
      Exercise::Representation::Search.(mode: :admin, representer_version: 1, mentor:, track:)
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

    representation_1 = create :exercise_representation, feedback_type: nil, num_submissions: 4,
      exercise: create(:practice_exercise, track: track_1)
    representation_2 = create :exercise_representation, feedback_type: nil, num_submissions: 3,
      exercise: create(:practice_exercise, track: track_2)
    representation_3 = create :exercise_representation, feedback_type: nil, num_submissions: 2,
      exercise: create(:practice_exercise, track: track_3)

    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(mentor: mentor_1.reload, mode: :without_feedback, representer_version: 1,
        track: [track_1, track_2, track_3])
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(mentor: mentor_2, mode: :without_feedback, representer_version: 1,
        track: [track_1, track_2, track_3])
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(mentor: mentor_3, mode: :without_feedback, representer_version: 1,
        track: [track_1, track_2, track_3])
  end

  test "filter: mentor when with_feedback is true returns representations where mentor is author or editor" do
    track = create :track
    mentor_1 = create :user
    mentor_2 = create :user
    mentor_3 = create :user
    representation_1 = create(:exercise_representation, feedback_type: :actionable, feedback_author: mentor_1, num_submissions: 4,
      track:)
    representation_2 = create(:exercise_representation, feedback_type: :actionable, feedback_author: mentor_1, num_submissions: 3,
      track:)
    representation_3 = create(:exercise_representation, feedback_type: :actionable, feedback_author: mentor_2, num_submissions: 2,
      track:)

    assert_equal [representation_1, representation_2],
      Exercise::Representation::Search.(mentor: mentor_1, mode: :with_feedback, representer_version: 1, track:)
    assert_equal [representation_3],
      Exercise::Representation::Search.(mentor: mentor_2, mode: :with_feedback, representer_version: 1, track:)
    assert_empty Exercise::Representation::Search.(mentor: mentor_3, mode: :with_feedback, representer_version: 1, track:)
  end

  test "filter: track" do
    mentor = create :user
    track_1 = create :track, :random_slug
    track_2 = create :track, :random_slug
    exercise_1 = create :practice_exercise, track: track_1
    exercise_2 = create :practice_exercise, track: track_2
    representation_1 = create :exercise_representation, exercise: exercise_1, num_submissions: 4, track: track_1
    representation_2 = create :exercise_representation, exercise: exercise_1, num_submissions: 3, track: track_1
    representation_3 = create :exercise_representation, exercise: exercise_2, num_submissions: 2, track: track_2

    assert_equal [representation_1, representation_2],
      Exercise::Representation::Search.(track: track_1, mode: :without_feedback, representer_version: 1, mentor:)
    assert_equal [representation_3],
      Exercise::Representation::Search.(track: track_2, mode: :without_feedback, representer_version: 1, mentor:)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(track: [track_1, track_2], mode: :without_feedback, representer_version: 1, mentor:)
  end

  test "filter: track is nil returns no records" do
    track = create :track, :random_slug
    exercise = create(:practice_exercise, track:)
    create(:exercise_representation, exercise:, num_submissions: 4, track:)
    create(:exercise_representation, exercise:, num_submissions: 3, track:)

    assert_empty Exercise::Representation::Search.(mode: :without_feedback, representer_version: 1, track: nil)
  end

  test "filter: only_mentored_solutions" do
    track = create :track
    exercise = create(:practice_exercise, track:)
    mentor_1 = create :user
    mentor_2 = create :user
    mentor_3 = create :user
    representation_1 = create(:exercise_representation, feedback_author: mentor_1, feedback_type: :actionable, num_submissions: 4,
      ast_digest: 'digest_1', exercise:, track:)
    representation_2 = create(:exercise_representation, feedback_author: mentor_2, feedback_type: :actionable, num_submissions: 3,
      ast_digest: 'digest_2', exercise:, track:)
    representation_3 = create(:exercise_representation, feedback_author: mentor_1, feedback_type: :actionable, num_submissions: 2,
      ast_digest: 'digest_3', exercise:, track:)
    create :submission_representation, ast_digest: representation_1.ast_digest, mentored_by: mentor_1,
      submission: create(:submission, exercise:)
    create :submission_representation, ast_digest: representation_2.ast_digest, submission: create(:submission, exercise:)
    create :submission_representation, ast_digest: representation_3.ast_digest, submission: create(:submission, exercise:)

    assert_equal [representation_1],
      Exercise::Representation::Search.(mentor: mentor_1.reload, only_mentored_solutions: true, mode: :with_feedback,
        representer_version: 1, track:)
    assert_equal [representation_1, representation_3],
      Exercise::Representation::Search.(mentor: mentor_1.reload, only_mentored_solutions: false, mode: :with_feedback,
        representer_version: 1, track:)
    assert_empty Exercise::Representation::Search.(mentor: mentor_2, only_mentored_solutions: true, mode: :with_feedback,
      representer_version: 1, track:)
    assert_equal [representation_2],
      Exercise::Representation::Search.(mentor: mentor_2, only_mentored_solutions: false, mode: :with_feedback,
        representer_version: 1, track:)
    assert_empty Exercise::Representation::Search.(mentor: mentor_3, only_mentored_solutions: true, mode: :with_feedback,
      representer_version: 1, track:)
    assert_empty Exercise::Representation::Search.(mentor: mentor_3, only_mentored_solutions: false, mode: :with_feedback,
      representer_version: 1, track:)
  end

  test "paginates" do
    track = create :track
    mentor = create :user
    25.times { create :exercise_representation, num_submissions: 3 }

    first_page = Exercise::Representation::Search.(mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal 20, first_page.limit_value # Sanity
    assert_equal 20, first_page.length
    assert_equal 1, first_page.current_page
    assert_equal 25, first_page.total_count

    second_page = Exercise::Representation::Search.(page: 2, mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal 5, second_page.length
    assert_equal 2, second_page.current_page
    assert_equal 25, second_page.total_count

    page = Exercise::Representation::Search.(paginated: false, mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal 25, page.length
  end

  test "sorts" do
    track = create :track
    mentor = create :user
    representation_1 = create(:exercise_representation, num_submissions: 3, last_submitted_at: Time.zone.now - 3.days, track:)
    representation_2 = create(:exercise_representation, num_submissions: 2, last_submitted_at: Time.zone.now - 5.days, track:)
    representation_3 = create(:exercise_representation, num_submissions: 8, last_submitted_at: Time.zone.now - 4.days, track:)

    # Default: order by num_submissions
    assert_equal [representation_3, representation_1, representation_2],
      Exercise::Representation::Search.(mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_3, representation_1, representation_2],
      Exercise::Representation::Search.(order: :most_submissions, mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_1, representation_3, representation_2],
      Exercise::Representation::Search.(order: :most_recent, mode: :without_feedback, representer_version: 1, mentor:, track:)
    assert_equal [representation_1, representation_2, representation_3],
      Exercise::Representation::Search.(sorted: false, mode: :without_feedback, representer_version: 1, mentor:, track:).order(:id)
  end
end
