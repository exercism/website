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
        slug: "csharp",
        title: "C#",
        icon_url: csharp.icon_url,
        num_solutions_queued: 6,
        median_wait_time: nil,
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'csharp')
        }
      },
      {
        slug: "fsharp",
        title: "F#",
        icon_url: fsharp.icon_url,
        num_solutions_queued: 0,
        median_wait_time: nil,
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'fsharp')
        }
      },
      {
        slug: "ruby",
        title: "Ruby",
        icon_url: ruby.icon_url,
        num_solutions_queued: 3,
        median_wait_time: nil,
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'ruby')
        }
      }
    ]
    actual = SerializeTracksForMentoring.(Track.where(id: [csharp, fsharp, ruby]), nil)
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
        slug: "csharp",
        title: "C#",
        icon_url: csharp.icon_url,
        num_solutions_queued: 6,
        median_wait_time: nil,
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'csharp')
        }
      },
      {
        slug: "elixir",
        title: "Elixir",
        icon_url: elixir.icon_url,
        num_solutions_queued: 4,
        median_wait_time: nil,
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'elixir')
        }
      },
      {
        slug: "fsharp",
        title: "F#",
        icon_url: fsharp.icon_url,
        num_solutions_queued: 0,
        median_wait_time: nil,
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'fsharp')
        }
      },
      {
        slug: "ruby",
        title: "Ruby",
        icon_url: ruby.icon_url,
        num_solutions_queued: 3,
        median_wait_time: nil,
        links: {
          exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: 'ruby')
        }
      }
    ]
    actual = SerializeTracksForMentoring.(Track.all, mentor)
    assert_equal expected, actual
  end

  test "respects blocking in counts" do
    mentor = create :user
    solution = create :practice_solution

    2.times { create :mentor_request, solution: create(:practice_solution) }
    create(:mentor_request, solution:)

    data = SerializeTracksForMentoring.(Track.all, mentor)
    assert_equal 3, data[0][:num_solutions_queued]

    create :mentor_student_relationship, mentor:, student: solution.user, blocked_by_student: true
    data = SerializeTracksForMentoring.(Track.all, mentor)
    assert_equal 2, data[0][:num_solutions_queued]
  end
end
