require 'test_helper'

class Solution::MentorRequest::RetrieveTracksTest < ActiveSupport::TestCase
  test "retrieves correctly" do
    user = create :user

    fsharp = create :track, slug: "fsharp", title: "F#" # Has no requests
    ruby = create :track, slug: "ruby", title: "Ruby"
    csharp = create :track, slug: "csharp", title: "C#"
    elixir = create :track, slug: "elixir", title: "Elixir" # Is not mentored

    create :user_track_mentorship, user: user, track: fsharp
    create :user_track_mentorship, user: user, track: ruby
    create :user_track_mentorship, user: user, track: csharp

    # This shouldn't be included
    strings = create :concept_exercise, track: ruby

    # These are csharp and should be included
    zipper = create :concept_exercise, track: csharp, slug: :zipper, title: "Zipper"
    bob = create :practice_exercise, track: csharp, slug: :bob, title: "Bob"
    create :practice_exercise, track: csharp, slug: :fred, title: "Fred"

    # This shouldn't be included
    elixir_exercise = create :practice_exercise, track: elixir, slug: :erik, title: "Erik"

    # Make some requests for each except fred
    3.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: strings) }
    2.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: zipper) }
    4.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: bob) }
    4.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: elixir_exercise) }

    expected = [
      {
        slug: "csharp",
        title: "C#",
        icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png",
        count: 6,
        selected: true,
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'csharp')
        }
      },
      {
        slug: "fsharp",
        title: "F#",
        icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png",
        count: 0,
        selected: false,
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'fsharp')
        }
      },
      {
        slug: "ruby",
        title: "Ruby",
        icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png",
        count: 3,
        selected: false,
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'ruby')
        }
      }
    ]
    actual = Solution::MentorRequest::RetrieveTracks.(user)
    assert_equal expected, actual
  end
end
