require "test_helper"

class Search::IndexSolutionTest < ActiveSupport::TestCase
  test "indexes solution" do
    user = create :user, handle: 'jane'
    track = create :track, slug: 'fsharp'
    exercise = create :practice_exercise, slug: 'bob', track: track
    solution = create :practice_solution,
      id: 6,
      num_stars: 3,
      num_loc: 55,
      created_at: Time.parse("2020-09-29T23:12:22.000Z").utc,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      user: user,
      exercise: exercise
    submission = create :submission, solution: solution
    create :iteration, submission: submission

    stub_request(:post, "https://local.exercism.io:9200/solutions/solution").
      with(
        body: {
          id: 6,
          exercise_slug: 'bob',
          track_slug: 'fsharp',
          author_handle: 'jane',
          created_at: "2020-09-29T23:12:22.000Z",
          published_at: "2020-10-17T02:39:37.000Z",
          num_stars: 3,
          num_loc: 55,
          out_of_date: false,
          tests_passed: false
        }.to_json
      ).
      to_return(status: 200, body: "", headers: {})

    Search::IndexSolution.(solution)
  end

  test "indexes out-of-date solution" do
    user = create :user, handle: 'jane'
    track = create :track, slug: 'fsharp'
    exercise = create :practice_exercise, slug: 'bob', track: track
    solution = create :practice_solution,
      id: 6,
      num_stars: 3,
      num_loc: 55,
      git_important_files_hash: 'different-hash',
      created_at: Time.parse("2020-09-29T23:12:22.000Z").utc,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      user: user,
      exercise: exercise
    submission = create :submission, solution: solution
    create :iteration, submission: submission

    stub_request(:post, "https://local.exercism.io:9200/solutions/solution").
      with(
        body: {
          id: 6,
          exercise_slug: 'bob',
          track_slug: 'fsharp',
          author_handle: 'jane',
          created_at: "2020-09-29T23:12:22.000Z",
          published_at: "2020-10-17T02:39:37.000Z",
          num_stars: 3,
          num_loc: 55,
          out_of_date: true,
          tests_passed: false
        }.to_json
      ).
      to_return(status: 200, body: "", headers: {})

    Search::IndexSolution.(solution)
  end

  test "indexes solution with tests passing" do
    user = create :user, handle: 'jane'
    track = create :track, slug: 'fsharp'
    exercise = create :practice_exercise, slug: 'bob', track: track
    solution = create :practice_solution,
      id: 6,
      num_stars: 3,
      num_loc: 55,
      created_at: Time.parse("2020-09-29T23:12:22.000Z").utc,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      user: user,
      exercise: exercise
    submission = create :submission, solution: solution, tests_status: :passed
    create :iteration, submission: submission

    stub_request(:post, "https://local.exercism.io:9200/solutions/solution").
      with(
        body: {
          id: 6,
          exercise_slug: 'bob',
          track_slug: 'fsharp',
          author_handle: 'jane',
          created_at: "2020-09-29T23:12:22.000Z",
          published_at: "2020-10-17T02:39:37.000Z",
          num_stars: 3,
          num_loc: 55,
          out_of_date: false,
          tests_passed: true
        }.to_json
      ).
      to_return(status: 200, body: "", headers: {})

    Search::IndexSolution.(solution)
  end

  test "indexes published iteration" do
    user = create :user, handle: 'jane'
    track = create :track, slug: 'fsharp'
    exercise = create :practice_exercise, slug: 'bob', track: track
    solution = create :practice_solution,
      id: 6,
      num_stars: 3,
      num_loc: 55,
      created_at: Time.parse("2020-09-29T23:12:22.000Z").utc,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      user: user,
      exercise: exercise
    submission_1 = create :submission, solution: solution, tests_status: :passed
    iteration_1 = create :iteration, submission: submission_1

    submission_2 = create :submission, solution: solution, tests_status: :failed
    create :iteration, submission: submission_2

    solution.update(published_iteration: iteration_1)

    stub_request(:post, "https://local.exercism.io:9200/solutions/solution").
      with(
        body: {
          id: 6,
          exercise_slug: 'bob',
          track_slug: 'fsharp',
          author_handle: 'jane',
          created_at: "2020-09-29T23:12:22.000Z",
          published_at: "2020-10-17T02:39:37.000Z",
          num_stars: 3,
          num_loc: 55,
          out_of_date: false,
          tests_passed: true
        }.to_json
      ).
      to_return(status: 200, body: "", headers: {})

    Search::IndexSolution.(solution.reload)
  end

  test "indexes latest iteration" do
    user = create :user, handle: 'jane'
    track = create :track, slug: 'fsharp'
    exercise = create :practice_exercise, slug: 'bob', track: track
    solution = create :practice_solution,
      id: 6,
      num_stars: 3,
      num_loc: 55,
      created_at: Time.parse("2020-09-29T23:12:22.000Z").utc,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      user: user,
      exercise: exercise
    submission_1 = create :submission, solution: solution, tests_status: :passed
    create :iteration, submission: submission_1

    submission_2 = create :submission, solution: solution, tests_status: :failed
    create :iteration, submission: submission_2

    stub_request(:post, "https://local.exercism.io:9200/solutions/solution").
      with(
        body: {
          id: 6,
          exercise_slug: 'bob',
          track_slug: 'fsharp',
          author_handle: 'jane',
          created_at: "2020-09-29T23:12:22.000Z",
          published_at: "2020-10-17T02:39:37.000Z",
          num_stars: 3,
          num_loc: 55,
          out_of_date: false,
          tests_passed: false
        }.to_json
      ).
      to_return(status: 200, body: "", headers: {})

    Search::IndexSolution.(solution.reload)
  end
end
