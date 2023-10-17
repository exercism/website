require 'test_helper'

class AssembleRepresentationContextTest < ActiveSupport::TestCase
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

    create :user_track_mentorship, :automator, user:, track: csharp, num_finished_discussions: 100
    create :user_track_mentorship, :automator, user:, track: clojure, num_finished_discussions: 100
    create :user_track_mentorship, :automator, user:, track: javascript, num_finished_discussions: 100
    create :user_track_mentorship, :automator, user:, track: ruby, num_finished_discussions: 100

    expected = {
      tracks: [
        { slug: csharp.slug, title: csharp.title, icon_url: csharp.icon_url, num_submissions: 1 },
        { slug: clojure.slug, title: clojure.title, icon_url: clojure.icon_url, num_submissions: 3 },
        { slug: javascript.slug, title: javascript.title, icon_url: javascript.icon_url, num_submissions: 1 },
        { slug: ruby.slug, title: ruby.title, icon_url: ruby.icon_url, num_submissions: 2 }
      ],
      representation_count: 7
    }
    assert_equal expected, AssembleRepresentationContext.(user)[:with_feedback]
  end

  test "without_feedback" do
    user = create :user
    track = create :track, :random_slug
    exercise = create(:practice_exercise, track:)

    create :exercise_representation, exercise:, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise:, feedback_type: :actionable, num_submissions: 3
    create :exercise_representation, exercise:, feedback_type: nil, num_submissions: 3

    create :user_track_mentorship, :automator, user:, track:, num_finished_discussions: 100

    expected = {
      tracks: [
        { slug: track.slug, title: track.title, icon_url: track.icon_url, num_submissions: 2 }
      ],
      representation_count: 2
    }
    assert_equal expected, AssembleRepresentationContext.(user)[:without_feedback]
  end

  test "with_feedback" do
    user_1 = create :user
    user_2 = create :user
    track = create :track, :random_slug
    exercise = create(:practice_exercise, track:)
    create :exercise_representation, exercise:, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise:, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise:, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise:, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise:, feedback_type: :actionable, feedback_author: user_2, num_submissions: 3

    create :user_track_mentorship, :automator, user: user_1, track:, num_finished_discussions: 100

    expected = {
      tracks: [
        { slug: track.slug, title: track.title, icon_url: track.icon_url, num_submissions: 2 }
      ],
      representation_count: 2
    }
    assert_equal expected, AssembleRepresentationContext.(user_1)[:with_feedback]
  end

  test "admin" do
    user_1 = create :user
    user_2 = create :user
    track = create :track, :random_slug
    exercise = create(:practice_exercise, track:)
    create :exercise_representation, exercise:, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise:, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise:, feedback_type: nil, num_submissions: 3
    create :exercise_representation, exercise:, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise:, feedback_type: :actionable, feedback_author: user_2, num_submissions: 3

    create :user_track_mentorship, :automator, user: user_1, track:, num_finished_discussions: 100

    expected = {
      tracks: [
        { slug: track.slug, title: track.title, icon_url: track.icon_url, num_submissions: 3 }
      ],
      representation_count: 3
    }
    assert_equal expected, AssembleRepresentationContext.(user_1)[:admin]
  end

  test "should select correct representer version" do
    skip # TODO: Work this out
    track = create :track
    mentor = create :user
    create :exercise_representation, track:, representer_version: 2
    create :exercise_representation, track:, representer_version: 5
    create :exercise_representation, track:, representer_version: 1

    Exercise::Representation::Search.expects(:call).with do |kwargs|
      assert_equal 5, kwargs[:representer_version]
    end.returns(Exercise::Representation.page(1).per(20))

    AssembleRepresentationContext.(mentor)
  end

  test "only considers representations with > 1 submissions" do
    user_1 = create :user
    user_2 = create :user
    track = create :track, :random_slug
    exercise = create(:practice_exercise, track:)
    create :exercise_representation, exercise:, feedback_type: :actionable, feedback_author: user_1, num_submissions: 4
    create :exercise_representation, exercise:, feedback_type: :actionable, feedback_author: user_1, num_submissions: 3
    create :exercise_representation, exercise:, feedback_type: :actionable, feedback_author: user_2, num_submissions: 2
    create :exercise_representation, exercise:, feedback_type: :actionable, feedback_author: user_2, num_submissions: 1

    create :user_track_mentorship, :automator, user: user_1, track:, num_finished_discussions: 100

    expected = {
      tracks: [
        { slug: track.slug, title: track.title, icon_url: track.icon_url, num_submissions: 2 }
      ],
      representation_count: 2
    }
    assert_equal expected, AssembleRepresentationContext.(user_1)[:with_feedback]
  end

  test "only considers tracks where user is an automator" do
    mentor = create :user
    staff = create :user, :staff
    other_user = create :user
    csharp = create :track, slug: :csharp, title: 'C#'
    ruby = create :track, slug: :ruby, title: 'Ruby'
    javascript = create :track, slug: :javascript, title: 'JavaScript'
    clojure = create :track, slug: :clojure, title: 'Clojure'

    [mentor, staff].each do |user|
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

      create :user_track_mentorship, :automator, user:, track: csharp
      create :user_track_mentorship, :automator, user:, track: clojure

      # Sanity check: ignore track where not an automator
      create :user_track_mentorship, user:, track: ruby
    end

    # Sanity check: ignore track with enough finished discussion but by other user
    create :user_track_mentorship, :automator, user: other_user, track: javascript

    expected = {
      tracks: [
        { slug: csharp.slug, title: csharp.title, icon_url: csharp.icon_url, num_submissions: 1 },
        { slug: clojure.slug, title: clojure.title, icon_url: clojure.icon_url, num_submissions: 3 }
      ],
      representation_count: 4
    }
    assert_equal expected, AssembleRepresentationContext.(mentor)[:with_feedback]

    expected = {
      tracks: [
        { slug: csharp.slug, title: csharp.title, icon_url: csharp.icon_url, num_submissions: 1 },
        { slug: clojure.slug, title: clojure.title, icon_url: clojure.icon_url, num_submissions: 3 },
        { slug: javascript.slug, title: javascript.title, icon_url: javascript.icon_url, num_submissions: 1 },
        { slug: ruby.slug, title: ruby.title, icon_url: ruby.icon_url, num_submissions: 2 }
      ],
      representation_count: 7
    }
    assert_equal expected, AssembleRepresentationContext.(staff)[:with_feedback]
  end
end
