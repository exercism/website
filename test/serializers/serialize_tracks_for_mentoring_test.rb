require 'test_helper'

class Mentor::Request::RetrieveTracksTest < ActiveSupport::TestCase
  test "serializes correctly without mentor" do
    fsharp = create :track, slug: "fsharp", title: "F#" # Has no requests
    ruby = create :track, slug: "ruby", title: "Ruby"
    csharp = create :track, slug: "csharp", title: "C#"
    elixir = create :track, slug: "elixir", title: "Elixir" # Is not mentored

    # This shouldn't be included
    strings = create :concept_exercise, track: ruby

    # These are csharp and should be included
    zipper = create :concept_exercise, track: csharp, slug: :zipper, title: "Zipper"
    bob = create :practice_exercise, track: csharp, slug: :bob, title: "Bob"
    create :practice_exercise, track: csharp, slug: :fred, title: "Fred"

    # This shouldn't be included
    elixir_exercise = create :practice_exercise, track: elixir, slug: :erik, title: "Erik"

    # Make some requests for each except fred
    3.times { create :mentor_request, solution: create(:concept_solution, exercise: strings) }
    2.times { create :mentor_request, solution: create(:concept_solution, exercise: zipper) }
    4.times { create :mentor_request, solution: create(:concept_solution, exercise: bob) }
    4.times { create :mentor_request, solution: create(:concept_solution, exercise: elixir_exercise) }

    expected = [
      {
        id: "csharp",
        title: "C#",
        icon_url: csharp.icon_url,
        num_solutions_queued: 6,
        avg_wait_time: "2 days",
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'csharp')
        }
      },
      {
        id: "fsharp",
        title: "F#",
        icon_url: fsharp.icon_url,
        num_solutions_queued: 0,
        avg_wait_time: "2 days",
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'fsharp')
        }
      },
      {
        id: "ruby",
        title: "Ruby",
        icon_url: ruby.icon_url,
        num_solutions_queued: 3,
        avg_wait_time: "2 days",
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'ruby')
        }
      }
    ]
    actual = SerializeTracksForMentoring.(Track.where(id: [csharp, fsharp, ruby]))
    assert_equal expected, actual
  end

  test "serializes correctly with mentor" do
    mentor = create :user

    fsharp = create :track, slug: "fsharp", title: "F#" # Has no requests
    ruby = create :track, slug: "ruby", title: "Ruby"
    csharp = create :track, slug: "csharp", title: "C#"
    elixir = create :track, slug: "elixir", title: "Elixir" # Is not mentored

    create :user_track_mentorship, user: mentor, track: fsharp
    create :user_track_mentorship, user: mentor, track: ruby
    create :user_track_mentorship, user: mentor, track: csharp

    # This shouldn't be included
    strings = create :concept_exercise, track: ruby

    # These are csharp and should be included
    zipper = create :concept_exercise, track: csharp, slug: :zipper, title: "Zipper"
    bob = create :practice_exercise, track: csharp, slug: :bob, title: "Bob"
    create :practice_exercise, track: csharp, slug: :fred, title: "Fred"

    # This shouldn't be included
    elixir_exercise = create :practice_exercise, track: elixir, slug: :erik, title: "Erik"

    # Make some requests for each except fred
    3.times { create :mentor_request, solution: create(:concept_solution, exercise: strings) }
    2.times { create :mentor_request, solution: create(:concept_solution, exercise: zipper) }
    4.times { create :mentor_request, solution: create(:concept_solution, exercise: bob) }
    4.times { create :mentor_request, solution: create(:concept_solution, exercise: elixir_exercise) }

    # These shouldn't be included as they're by the user
    create :mentor_request, solution: create(:concept_solution, exercise: strings, user: mentor)
    create :mentor_request, solution: create(:concept_solution, exercise: zipper, user: mentor)
    create :mentor_request, solution: create(:concept_solution, exercise: elixir_exercise, user: mentor)

    expected = [
      {
        id: "csharp",
        title: "C#",
        icon_url: csharp.icon_url,
        num_solutions_queued: 6,
        avg_wait_time: "2 days",
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'csharp')
        }
      },
      {
        id: "elixir",
        title: "Elixir",
        icon_url: elixir.icon_url,
        num_solutions_queued: 4,
        avg_wait_time: "2 days",
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'elixir')
        }
      },
      {
        id: "fsharp",
        title: "F#",
        icon_url: fsharp.icon_url,
        num_solutions_queued: 0,
        avg_wait_time: "2 days",
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'fsharp')
        }
      },
      {
        id: "ruby",
        title: "Ruby",
        icon_url: ruby.icon_url,
        num_solutions_queued: 3,
        avg_wait_time: "2 days",
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'ruby')
        }
      }
    ]
    actual = SerializeTracksForMentoring.(Track.all, mentor: mentor)
    assert_equal expected, actual
  end
end
