require 'test_helper'

class AssembleRepresentationTracksForSelectTest < ActiveSupport::TestCase
  test "ordered by title ascending" do
    user = create :user
    csharp = create :track, slug: :csharp, title: 'C#'
    ruby = create :track, slug: :ruby, title: 'Ruby'
    javascript = create :track, slug: :javascript, title: 'JavaScript'
    clojure = create :track, slug: :clojure, title: 'Clojure'

    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: csharp), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: ruby), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: ruby), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: javascript),
      feedback_type: :actionable, feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: clojure), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: clojure), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: clojure), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3

    create_list(:mentor_discussion, 100, :student_finished, track: csharp, mentor: user)
    create_list(:mentor_discussion, 100, :student_finished, track: clojure, mentor: user)
    create_list(:mentor_discussion, 100, :student_finished, track: javascript, mentor: user)
    create_list(:mentor_discussion, 100, :student_finished, track: ruby, mentor: user)

    expected = [
      { slug: csharp.slug, title: csharp.title, icon_url: csharp.icon_url, num_submissions: 1 },
      { slug: clojure.slug, title: clojure.title, icon_url: clojure.icon_url, num_submissions: 3 },
      { slug: javascript.slug, title: javascript.title, icon_url: javascript.icon_url, num_submissions: 1 },
      { slug: ruby.slug, title: ruby.title, icon_url: ruby.icon_url, num_submissions: 2 }
    ]
    assert_equal expected, AssembleRepresentationTracksForSelect.(user, with_feedback: true)
  end

  test "status is without_feedback" do
    user = create :user
    track = create :track, :random_slug
    create :user_track_mentorship, user: user, track: track
    exercise = create :practice_exercise, track: track

    create :exercise_representation, exercise: exercise, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise: exercise, feedback_type: :actionable, num_submissions: 3
    create :exercise_representation, exercise: exercise, feedback_type: nil, num_submissions: 3

    create_list(:mentor_discussion, 100, :student_finished, track:, mentor: user)

    expected = [
      { slug: track.slug, title: track.title, icon_url: track.icon_url, num_submissions: 2 }
    ]
    assert_equal expected, AssembleRepresentationTracksForSelect.(user, with_feedback: false)
  end

  test "status is with_feedback" do
    user_1 = create :user
    user_2 = create :user
    track = create :track, :random_slug
    exercise = create :practice_exercise, track: track
    create :exercise_representation, exercise: exercise, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise: exercise, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise: exercise, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise: exercise, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise: exercise, feedback_type: :actionable, feedback_author: user_2, num_submissions: 3

    create_list(:mentor_discussion, 100, :student_finished, track:, mentor: user_1)

    expected = [
      { slug: track.slug, title: track.title, icon_url: track.icon_url, num_submissions: 2 }
    ]
    assert_equal expected, AssembleRepresentationTracksForSelect.(user_1, with_feedback: true)
  end

  test "only considers representations with > 1 submissions" do
    user_1 = create :user
    user_2 = create :user
    track = create :track, :random_slug
    exercise = create :practice_exercise, track: track
    create :exercise_representation, exercise: exercise, feedback_type: :actionable, feedback_author: user_1, num_submissions: 4
    create :exercise_representation, exercise: exercise, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise: exercise, feedback_type: :actionable, feedback_author: user_2, num_submissions: 2
    create :exercise_representation, exercise: exercise, feedback_type: :actionable, feedback_author: user_2, num_submissions: 1

    create_list(:mentor_discussion, 100, :student_finished, track:, mentor: user_1)

    expected = [
      { slug: track.slug, title: track.title, icon_url: track.icon_url, num_submissions: 2 }
    ]
    assert_equal expected, AssembleRepresentationTracksForSelect.(user_1, with_feedback: true)
  end

  test "only considers tracks where user has mentored 100 or more solutions" do
    user = create :user
    other_user = create :user
    csharp = create :track, slug: :csharp, title: 'C#'
    ruby = create :track, slug: :ruby, title: 'Ruby'
    javascript = create :track, slug: :javascript, title: 'JavaScript'
    clojure = create :track, slug: :clojure, title: 'Clojure'

    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: csharp), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: ruby), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: ruby), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: javascript),
      feedback_type: :actionable, feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: clojure), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: clojure), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: clojure), feedback_type: :actionable,
      feedback_author: user, num_submissions: 3

    # Sanity check
    assert_empty AssembleRepresentationTracksForSelect.(user, with_feedback: true)

    # Sanity check: just below threshold
    create_list(:mentor_discussion, 99, :student_finished, track: csharp, mentor: user)
    assert_empty AssembleRepresentationTracksForSelect.(user, with_feedback: true)

    # Sanity check: ignore discussion with status: awaiting_student
    create :mentor_discussion, :awaiting_student, track: csharp, mentor: user
    assert_empty AssembleRepresentationTracksForSelect.(user, with_feedback: true)

    # Sanity check: ignore discussion with status: awaiting_mentor
    create :mentor_discussion, :awaiting_mentor, track: csharp, mentor: user
    assert_empty AssembleRepresentationTracksForSelect.(user, with_feedback: true)

    # Sanity check: ignore discussion with status: mentor_finished
    create :mentor_discussion, :mentor_finished, track: csharp, mentor: user
    assert_empty AssembleRepresentationTracksForSelect.(user, with_feedback: true)

    # Sanity check: ignore discussion of other mentor
    create :mentor_discussion, :student_finished, track: csharp, mentor: other_user
    assert_empty AssembleRepresentationTracksForSelect.(user, with_feedback: true)

    create :mentor_discussion, :student_finished, track: csharp, mentor: user
    expected = [
      { slug: csharp.slug, title: csharp.title, icon_url: csharp.icon_url, num_submissions: 1 }
    ]
    assert_equal expected, AssembleRepresentationTracksForSelect.(user, with_feedback: true)

    create_list(:mentor_discussion, 115, :student_finished, track: clojure, mentor: user)
    expected = [
      { slug: csharp.slug, title: csharp.title, icon_url: csharp.icon_url, num_submissions: 1 },
      { slug: clojure.slug, title: clojure.title, icon_url: clojure.icon_url, num_submissions: 3 }
    ]
    assert_equal expected, AssembleRepresentationTracksForSelect.(user, with_feedback: true)
  end
end
