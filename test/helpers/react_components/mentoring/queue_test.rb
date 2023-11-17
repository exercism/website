require_relative "../react_component_test_case"

class ReactComponents::Mentoring::QueueTest < ReactComponentTestCase
  test "mentoring queue rendered correctly" do
    user = create :user

    fsharp = create :track, slug: "fsharp", title: "F#" # Has no requests
    ruby = create :track, slug: "ruby", title: "Ruby"
    csharp = create :track, slug: "csharp", title: "C#"

    create :user_track_mentorship, user:, track: fsharp
    create :user_track_mentorship, user:, track: ruby
    create :user_track_mentorship, user:, track: csharp

    # This shouldn't be included
    strings = create :concept_exercise, track: ruby

    # These are csharp and should be included
    zipper = create :concept_exercise, track: csharp, slug: :zipper, title: "Zipper"
    bob = create :practice_exercise, track: csharp, slug: :bob, title: "Bob"
    fred = create :practice_exercise, track: csharp, slug: :fred, title: "Fred"

    # Make some requests for each except fred
    3.times { create :mentor_request, solution: create(:concept_solution, exercise: strings) }
    2.times { create :mentor_request, solution: create(:concept_solution, exercise: zipper) }
    4.times { create :mentor_request, solution: create(:concept_solution, exercise: bob) }

    # Create mentor solutions to fred and zipper, with zipper completed
    create :concept_solution, user:, exercise: fred
    create :concept_solution, user:, exercise: zipper, completed_at: Time.current

    params = {
      criteria: "bo",
      track_slug: "csharp",
      exercise_slug: "bob"
    }
    component = ReactComponents::Mentoring::Queue.new(user, params)

    assert_component component,
      "mentoring-queue",
      {
        queue_request: {
          endpoint: Exercism::Routes.api_mentoring_requests_path,
          query: {
            criteria: "bo",
            track_slug: "csharp",
            exercise_slug: "bob"
          },
          options: {
            initial_data: AssembleMentorRequests.(user, params)
          }
        },
        tracks_request: {
          endpoint: Exercism::Routes.mentored_api_mentoring_tracks_url,
          options: {
            initial_data: {
              tracks: [
                {
                  slug: "csharp",
                  title: "C#",
                  icon_url: csharp.icon_url,
                  num_solutions_queued: 6,
                  median_wait_time: nil,
                  links: {
                    exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: csharp.slug)
                  }
                },
                {
                  slug: "fsharp",
                  title: "F#",
                  icon_url: fsharp.icon_url,
                  num_solutions_queued: 0,
                  median_wait_time: nil,
                  links: {
                    exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: fsharp.slug)
                  }
                },
                {
                  slug: "ruby",
                  title: "Ruby",
                  icon_url: ruby.icon_url,
                  num_solutions_queued: 3,
                  median_wait_time: nil,
                  links: {
                    exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: ruby.slug)
                  }
                }
              ]
            }
          }
        },
        default_track: {
          slug: "csharp",
          title: "C#",
          icon_url: csharp.icon_url,
          num_solutions_queued: 6,
          median_wait_time: nil,
          links: {
            exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: csharp.slug)
          },
          exercises: [
            {
              slug: "bob",
              title: "Bob",
              icon_url: bob.icon_url,
              count: 4,
              completed_by_mentor: false
            },
            {
              slug: "fred",
              title: "Fred",
              icon_url: fred.icon_url,
              count: 0,
              completed_by_mentor: false
            },
            {
              slug: "zipper",
              title: "Zipper",
              icon_url: zipper.icon_url,
              count: 2,
              completed_by_mentor: true
            }
          ]
        },
        default_exercise: {
          slug: "bob",
          title: "Bob",
          icon_url: bob.icon_url,
          count: 4,
          completed_by_mentor: false
        },
        sort_options: [

          { value: "", label: "Sort by oldest first" },
          { value: "recent", label: "Sort by recent first" }
        ],
        links: {
          tracks: Exercism::Routes.api_mentoring_tracks_url,
          update_tracks: Exercism::Routes.api_mentoring_tracks_url
        }
      }
  end

  test "mentoring queue renders requests for last seen track" do
    user = create :user

    ruby = create :track, slug: "ruby", title: "Ruby"
    csharp = create :track, slug: "csharp", title: "C#"

    create :user_track_mentorship, user:, track: ruby
    create :user_track_mentorship, user:, track: csharp, last_viewed: true

    # This shouldn't be included
    strings = create :concept_exercise, track: ruby

    # These are csharp and should be included
    zipper = create :concept_exercise, track: csharp, slug: :zipper, title: "Zipper"
    bob = create :practice_exercise, track: csharp, slug: :bob, title: "Bob"
    fred = create :practice_exercise, track: csharp, slug: :fred, title: "Fred"

    # Make some requests for each except fred
    3.times { create :mentor_request, solution: create(:concept_solution, exercise: strings) }
    2.times { create :mentor_request, solution: create(:concept_solution, exercise: zipper) }
    4.times { create :mentor_request, solution: create(:concept_solution, exercise: bob) }

    # Create mentor solutions to fred and zipper, with zipper completed
    create :concept_solution, user:, exercise: fred
    create :concept_solution, user:, exercise: zipper, completed_at: Time.current

    component = ReactComponents::Mentoring::Queue.new(user, {})

    assert_component component,
      "mentoring-queue",
      {
        queue_request: {
          endpoint: Exercism::Routes.api_mentoring_requests_path,
          query: { track_slug: "csharp" },
          options: {
            initial_data: AssembleMentorRequests.(user, { track_slug: "csharp" })
          }
        },
        tracks_request: {
          endpoint: Exercism::Routes.mentored_api_mentoring_tracks_url,
          options: {
            initial_data: {
              tracks: [
                {
                  slug: "csharp",
                  title: "C#",
                  icon_url: csharp.icon_url,
                  num_solutions_queued: 6,
                  median_wait_time: nil,
                  links: {
                    exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: csharp.slug)
                  }
                },
                {
                  slug: "ruby",
                  title: "Ruby",
                  icon_url: ruby.icon_url,
                  num_solutions_queued: 3,
                  median_wait_time: nil,
                  links: {
                    exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: ruby.slug)
                  }
                }
              ]
            }
          }
        },
        default_track: {
          slug: "csharp",
          title: "C#",
          icon_url: csharp.icon_url,
          num_solutions_queued: 6,
          median_wait_time: nil,
          links: {
            exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: csharp.slug)
          },
          exercises: [
            {
              slug: "bob",
              title: "Bob",
              icon_url: bob.icon_url,
              count: 4,
              completed_by_mentor: false
            },
            {
              slug: "fred",
              title: "Fred",
              icon_url: fred.icon_url,
              count: 0,
              completed_by_mentor: false
            },
            {
              slug: "zipper",
              title: "Zipper",
              icon_url: zipper.icon_url,
              count: 2,
              completed_by_mentor: true
            }
          ]
        },
        default_exercise: nil,
        sort_options: [

          { value: "", label: "Sort by oldest first" },
          { value: "recent", label: "Sort by recent first" }
        ],
        links: {
          tracks: Exercism::Routes.api_mentoring_tracks_url,
          update_tracks: Exercism::Routes.api_mentoring_tracks_url
        }
      }
  end

  test "mentoring queue honours current track" do
    user = create :user

    fsharp = create :track, slug: "fsharp", title: "F#" # Has no requests
    csharp = create :track, slug: "csharp", title: "C#"
    ruby = create :track, slug: "ruby", title: "Ruby"

    create :user_track_mentorship, user:, track: fsharp
    ruby_mentorship = create :user_track_mentorship, user:, track: ruby
    create :user_track_mentorship, user:, track: csharp

    # These are csharp and should be included
    bob = create :practice_exercise, track: fsharp, slug: :bob, title: "Bob"
    fred = create :practice_exercise, track: csharp, slug: :fred, title: "Fred"
    zipper = create :concept_exercise, track: ruby, slug: :zipper, title: "Zipper"

    # Make some requests for each except fred
    4.times { create :mentor_request, solution: create(:concept_solution, exercise: bob) }
    3.times { create :mentor_request, solution: create(:concept_solution, exercise: fred) }
    2.times { create :mentor_request, solution: create(:concept_solution, exercise: zipper) }

    # With none it takes alphabetical
    component = ReactComponents::Mentoring::Queue.new(user, {})
    refute_includes component.to_s, 'zipper'
    assert_includes component.to_s, 'fred'

    ruby_mentorship.update!(last_viewed: true)

    component = ReactComponents::Mentoring::Queue.new(user.reload, {})
    assert_includes component.to_s, 'zipper'
  end

  test "mentoring queue defaults to first track if there are none" do
    user = create :user

    create :track, slug: "fsharp", title: "F#"
    create :track, slug: "csharp", title: "C#"
    create :track, slug: "ruby", title: "Ruby"

    component = ReactComponents::Mentoring::Queue.new(user.reload, {})
    assert_includes component.to_s, "fsharp"
  end
end
