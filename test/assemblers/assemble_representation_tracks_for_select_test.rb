require 'test_helper'

class AssembleRepresentationTracksForSelectTest < ActiveSupport::TestCase
  test "ordered by title ascending" do
    csharp = create :track, slug: :csharp, title: 'C#'
    ruby = create :track, slug: :ruby, title: 'Ruby'
    javascript = create :track, slug: :javascript, title: 'JavaScript'
    clojure = create :track, slug: :clojure, title: 'Clojure'

    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: csharp)
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: ruby)
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: ruby)
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: javascript)
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: clojure)
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: clojure)
    create :exercise_representation, exercise: create(:practice_exercise, :random_slug, track: clojure)
    representations = Exercise::Representation.joins(exercise: :track)

    expected = [
      { slug: nil, title: 'All Tracks', icon_url: "ICON", num_submissions: 7 },
      { slug: csharp.slug, title: csharp.title, icon_url: csharp.icon_url, num_submissions: 1 },
      { slug: clojure.slug, title: clojure.title, icon_url: clojure.icon_url, num_submissions: 3 },
      { slug: javascript.slug, title: javascript.title, icon_url: javascript.icon_url, num_submissions: 1 },
      { slug: ruby.slug, title: ruby.title, icon_url: ruby.icon_url, num_submissions: 2 }
    ]
    assert_equal expected, AssembleRepresentationTracksForSelect.(representations)
  end
end
