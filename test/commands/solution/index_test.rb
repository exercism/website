require "test_helper"

class Solution::IndexTest < ActiveSupport::TestCase
  test "indexes solution" do
    user = create :user, id: 7, handle: 'jane'
    track = create :track, id: 11, slug: 'fsharp'
    exercise = create :practice_exercise, id: 13, slug: 'bob', track: track
    solution = create :practice_solution,
      id: 17,
      num_stars: 3,
      num_loc: 55,
      num_views: 20,
      num_comments: 2,
      user: user,
      exercise: exercise
    submission = create :submission, solution: solution    
    submission_file = create :submission_file, submission: submission, content: "module LogLineParser"
    iteration = create :iteration, submission: submission
    solution.update!(
      published_iteration: iteration,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      last_iterated_at: Time.parse("2021-02-22T11:22:33.000Z").utc)

    stub_request(:post, "https://opensearch:9200/solutions/solution").
      with(
        body: {
          id: 17,
          exercise_id: 13,
          exercise_slug: 'bob',
          track_id: 11,
          track_slug: 'fsharp',
          author_id: 7,
          author_handle: 'jane',
          last_iterated_at: "2021-02-22T11:22:33.000Z",
          published_at: "2020-10-17T02:39:37.000Z",
          num_stars: 3,
          num_loc: 55,
          num_comments: 2,
          num_views: 20,
          out_of_date: false,
          status: 'published',
          mentoring_status: 'none',
          published_iteration: {
            tests_passed: false,
            code: ["module LogLineParser"]
          },
          latest_iteration: {
            tests_passed: false,
            code: ["module LogLineParser"]
          }
        }.to_json
      ).
      to_return(status: 200, body: "", headers: {})

    Solution::Index.(solution)
  end

  test "indexes out-of-date solution" do
    user = create :user, id: 7, handle: 'jane'
    track = create :track, id: 11, slug: 'fsharp'
    exercise = create :practice_exercise, id: 13, slug: 'bob', track: track
    solution = create :practice_solution,
      id: 17,
      num_stars: 3,
      num_loc: 55,
      num_views: 20,
      num_comments: 2,
      user: user,
      exercise: exercise,
      git_important_files_hash: 'different-hash' # Makes the solution out-of-date
    submission = create :submission, solution: solution    
    submission_file = create :submission_file, submission: submission, content: "module LogLineParser"
    iteration = create :iteration, submission: submission
    solution.update!(
      published_iteration: iteration,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      last_iterated_at: Time.parse("2021-02-22T11:22:33.000Z").utc)

    stub_request(:post, "https://opensearch:9200/solutions/solution").
      with(
        body: {
          id: 17,
          exercise_id: 13,
          exercise_slug: 'bob',
          track_id: 11,
          track_slug: 'fsharp',
          author_id: 7,
          author_handle: 'jane',
          last_iterated_at: "2021-02-22T11:22:33.000Z",
          published_at: "2020-10-17T02:39:37.000Z",
          num_stars: 3,
          num_loc: 55,
          num_comments: 2,
          num_views: 20,
          out_of_date: true,
          status: 'published',
          mentoring_status: 'none',
          published_iteration: {
            tests_passed: false,
            code: ["module LogLineParser"]
          },
          latest_iteration: {
            tests_passed: false,
            code: ["module LogLineParser"]
          }
        }.to_json
      ).
      to_return(status: 200, body: "", headers: {})

    Solution::Index.(solution)
  end

  test "indexes solution with tests passing" do
    user = create :user, id: 7, handle: 'jane'
    track = create :track, id: 11, slug: 'fsharp'
    exercise = create :practice_exercise, id: 13, slug: 'bob', track: track
    solution = create :practice_solution,
      id: 17,
      num_stars: 3,
      num_loc: 55,
      num_views: 20,
      num_comments: 2,
      user: user,
      exercise: exercise
    submission = create :submission, solution: solution, tests_status: :passed   
    submission_file = create :submission_file, submission: submission, content: "module LogLineParser"
    iteration = create :iteration, submission: submission
    solution.update!(
      published_iteration: iteration,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      last_iterated_at: Time.parse("2021-02-22T11:22:33.000Z").utc)

    stub_request(:post, "https://opensearch:9200/solutions/solution").
      with(
        body: {
          id: 17,
          exercise_id: 13,
          exercise_slug: 'bob',
          track_id: 11,
          track_slug: 'fsharp',
          author_id: 7,
          author_handle: 'jane',
          last_iterated_at: "2021-02-22T11:22:33.000Z",
          published_at: "2020-10-17T02:39:37.000Z",
          num_stars: 3,
          num_loc: 55,
          num_comments: 2,
          num_views: 20,
          out_of_date: false,
          status: 'published',
          mentoring_status: 'none',
          published_iteration: {
            tests_passed: true,
            code: ["module LogLineParser"]
          },
          latest_iteration: {
            tests_passed: true,
            code: ["module LogLineParser"]
          }
        }.to_json
      ).
      to_return(status: 200, body: "", headers: {})

    Solution::Index.(solution)
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

    Solution::Index.(solution.reload)
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

    Solution::Index.(solution.reload)
  end
end
