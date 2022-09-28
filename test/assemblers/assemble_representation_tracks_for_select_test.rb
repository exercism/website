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

    expected = [
      { slug: track.slug, title: track.title, icon_url: track.icon_url, num_submissions: 2 }
    ]
    assert_equal expected, AssembleRepresentationTracksForSelect.(user_1, with_feedback: true)
  end
end
