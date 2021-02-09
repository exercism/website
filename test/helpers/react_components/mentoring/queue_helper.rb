require_relative "../react_component_test_case"

class MentoringQueueTest < ReactComponentTestCase
  test "mentoring queue rendered correctly" do
    request = { endpoint: "conversations-endpoint" }

    user = create :user

    create :track, slug: "fsharp", title: "F#" # Has no requests
    ruby = create :track, slug: "ruby", title: "Ruby"
    csharp = create :track, slug: "csharp", title: "C#"

    # This shouldn't be included
    strings = create :concept_exercise, track: ruby

    # These are csharp and should be included
    zipper = create :concept_exercise, track: csharp, slug: :zipper, title: "Zipper"
    bob = create :practice_exercise, track: csharp, slug: :bob, title: "Bob"
    fred = create :practice_exercise, track: csharp, slug: :fred, title: "Fred"

    # Make some requests for each except fred
    3.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: strings) }
    2.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: zipper) }
    4.times { create :solution_mentor_request, solution: create(:concept_solution, exercise: bob) }

    # Create mentor solutions to fred and zipper, with zipper completed
    create :concept_solution, user: user, exercise: fred
    create :concept_solution, user: user, exercise: zipper, completed_at: Time.current

    component = ReactComponents::Mentoring::Queue.new(user, request)

    assert_component component,
      "mentoring-queue",
      {
        request: request,
        tracks: [
          {
            slug: "csharp",
            title: "C#",
            icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png",
            count: 6,
            selected: true
          },
          {
            slug: "fsharp",
            title: "F#",
            icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png",
            count: 0,
            selected: false
          },
          {
            slug: "ruby",
            title: "Ruby",
            icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png",
            count: 3,
            selected: false
          }
        ],
        exercises: [
          {
            slug: "bob",
            title: "Bob",
            icon_name: "sample-exercise-butterflies",
            count: 4,
            completed_by_mentor: false
          },
          {
            slug: "fred",
            title: "Fred",
            icon_name: "sample-exercise-butterflies",
            count: 0,
            completed_by_mentor: false
          },
          {
            slug: "zipper",
            title: "Zipper",
            icon_name: "sample-exercise-rocket",
            count: 2,
            completed_by_mentor: true
          }
        ],
        sort_options: [
          { value: 'recent', label: 'Sort by Most Recent' },
          { value: 'exercise', label: 'Sort by Exercise' },
          { value: 'student', label: 'Sort by Student' }
        ]
      }
  end
end
