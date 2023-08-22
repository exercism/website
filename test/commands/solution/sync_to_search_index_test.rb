require "test_helper"

class Solution::SyncToSearchIndexTest < ActiveSupport::TestCase
  test "indexes solution" do
    user = create :user, id: 7, handle: 'jane'
    track = create :track, id: 11, slug: 'fsharp', title: 'F#'
    exercise = create(:practice_exercise, id: 13, slug: 'bob', title: 'Bob', track:)
    solution = create :practice_solution,
      id: 17,
      num_stars: 3,
      num_loc: 55,
      num_views: 20,
      num_comments: 2,
      user:,
      exercise:,
      published_iteration_head_tests_status: :failed
    submission = create :submission, solution:, tests_status: :passed
    create :submission_file, submission:, content: "module LogLineParser"
    iteration = create(:iteration, submission:)

    solution.update!(
      published_iteration: iteration,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      last_iterated_at: Time.parse("2021-02-22T11:22:33.000Z").utc
    )

    Solution::SyncToSearchIndex.(solution)

    doc = get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution.id)
    expected = {
      "_index" => "test-solutions",
      "_id" => "17",
      "found" => true,
      "_source" => {
        "id" => 17,
        "last_iterated_at" => "2021-02-22T11:22:33.000Z",
        "published_at" => "2020-10-17T02:39:37.000Z",
        "num_stars" => 3,
        "num_loc" => 55,
        "num_comments" => 2,
        "num_views" => 20,
        "out_of_date" => false,
        "status" => "published",
        "mentoring_status" => "none",
        "exercise" => {
          "id" => 13,
          "slug" => "bob",
          "title" => "Bob"
        },
        "track" => { "id" => 11, "slug" => "fsharp", "title" => "F#" },
        "user" => { "id" => 7, "handle" => "jane" },
        "published_iteration" => { "tests_status" => "passed", "head_tests_status" => "failed", "code" => ["module LogLineParser"] },
        "latest_iteration" => { "tests_status" => "passed", "head_tests_status" => "not_queued", "code" => ["module LogLineParser"] }
      }
    }
    assert_equal expected, doc.except("_version", "_seq_no", "_primary_term")
  end

  test "indexes out-of-date solution" do
    user = create :user, id: 7, handle: 'jane'
    track = create :track, id: 11, slug: 'fsharp', title: 'F#'
    exercise = create(:practice_exercise, id: 13, slug: 'bob', title: 'Bob', track:)
    solution = create :practice_solution,
      id: 17,
      num_stars: 3,
      num_loc: 55,
      num_views: 20,
      num_comments: 2,
      user:,
      exercise:,
      published_iteration_head_tests_status: :failed,
      git_important_files_hash: 'different-hash' # Makes the solution out-of-date
    submission = create :submission, solution:, tests_status: :failed
    create :submission_file, submission:, content: "module LogLineParser"
    iteration = create(:iteration, submission:)
    solution.update!(
      published_iteration: iteration,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      last_iterated_at: Time.parse("2021-02-22T11:22:33.000Z").utc
    )

    Solution::SyncToSearchIndex.(solution)

    doc = get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution.id)
    expected = {
      "_index" => "test-solutions",
      "_id" => "17",
      "found" => true,
      "_source" => {
        "id" => 17,
        "last_iterated_at" => "2021-02-22T11:22:33.000Z",
        "published_at" => "2020-10-17T02:39:37.000Z",
        "num_stars" => 3,
        "num_loc" => 55,
        "num_comments" => 2,
        "num_views" => 20,
        "out_of_date" => true,
        "status" => "published",
        "mentoring_status" => "none",
        "exercise" => {
          "id" => 13,
          "slug" => "bob",
          "title" => "Bob"
        },
        "track" => { "id" => 11, "slug" => "fsharp", "title" => "F#" },
        "user" => { "id" => 7, "handle" => "jane" },
        "published_iteration" => { "tests_status" => "failed", "head_tests_status" => "failed", "code" => ["module LogLineParser"] },
        "latest_iteration" => { "tests_status" => "failed", "head_tests_status" => "not_queued", "code" => ["module LogLineParser"] }
      }
    }
    assert_equal expected, doc.except("_version", "_seq_no", "_primary_term")
  end

  test "indexes solution with tests passing" do
    user = create :user, id: 7, handle: 'jane'
    track = create :track, id: 11, slug: 'fsharp', title: 'F#'
    exercise = create(:practice_exercise, id: 13, slug: 'bob', title: 'Bob', track:)
    solution = create :practice_solution,
      id: 17,
      num_stars: 3,
      num_loc: 55,
      num_views: 20,
      num_comments: 2,
      user:,
      exercise:,
      published_iteration_head_tests_status: :passed
    submission = create :submission, solution:, tests_status: :passed
    create :submission_file, submission:, content: "module LogLineParser"
    iteration = create(:iteration, submission:)
    solution.update!(
      published_iteration: iteration,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      last_iterated_at: Time.parse("2021-02-22T11:22:33.000Z").utc
    )

    Solution::SyncToSearchIndex.(solution)

    doc = get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution.id)
    expected = {
      "_index" => "test-solutions",
      "_id" => "17",
      "found" => true,
      "_source" => {
        "id" => 17,
        "last_iterated_at" => "2021-02-22T11:22:33.000Z",
        "published_at" => "2020-10-17T02:39:37.000Z",
        "num_stars" => 3,
        "num_loc" => 55,
        "num_comments" => 2,
        "num_views" => 20,
        "out_of_date" => false,
        "status" => "published",
        "mentoring_status" => "none",
        "exercise" => {
          "id" => 13,
          "slug" => "bob",
          "title" => "Bob"
        },
        "track" => { "id" => 11, "slug" => "fsharp", "title" => "F#" },
        "user" => { "id" => 7, "handle" => "jane" },
        "published_iteration" => { "tests_status" => "passed", "head_tests_status" => "passed", "code" => ["module LogLineParser"] },
        "latest_iteration" => { "tests_status" => "passed", "head_tests_status" => "not_queued", "code" => ["module LogLineParser"] }
      }
    }
    assert_equal expected, doc.except("_version", "_seq_no", "_primary_term")
  end

  test "indexes solution with published and latest iteration" do
    user = create :user, id: 7, handle: 'jane'
    track = create :track, id: 11, slug: 'fsharp', title: 'F#'
    exercise = create(:practice_exercise, id: 13, slug: 'bob', title: 'Bob', track:)
    solution = create :practice_solution,
      id: 17,
      num_stars: 3,
      num_loc: 55,
      num_views: 20,
      num_comments: 2,
      user:,
      exercise:,
      published_iteration_head_tests_status: :passed

    submission_1 = create :submission, solution:, tests_status: :failed
    create :submission_file, submission: submission_1, content: "module LogLineParser"
    iteration_1 = create :iteration, submission: submission_1

    submission_2 = create :submission, solution:, tests_status: :passed
    create :submission_file, submission: submission_2, content: "module LogLineParser\n\nlet parse str = 2"
    create :iteration, submission: submission_2

    solution.update!(
      published_iteration: iteration_1,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      last_iterated_at: Time.parse("2021-02-22T11:22:33.000Z").utc
    )

    Solution::SyncToSearchIndex.(solution)

    doc = get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution.id)
    expected = {
      "_index" => "test-solutions",
      "_id" => "17",
      "found" => true,
      "_source" => {
        "id" => 17,
        "last_iterated_at" => "2021-02-22T11:22:33.000Z",
        "published_at" => "2020-10-17T02:39:37.000Z",
        "num_stars" => 3,
        "num_loc" => 55,
        "num_comments" => 2,
        "num_views" => 20,
        "out_of_date" => false,
        "status" => "published",
        "mentoring_status" => "none",
        "exercise" => {
          "id" => 13,
          "slug" => "bob",
          "title" => "Bob"
        },
        "track" => { "id" => 11, "slug" => "fsharp", "title" => "F#" },
        "user" => { "id" => 7, "handle" => "jane" },
        "published_iteration" => { "tests_status" => "failed", "head_tests_status" => "passed", "code" => ["module LogLineParser"] },
        "latest_iteration" => { "tests_status" => "passed", "head_tests_status" => "not_queued",
                                "code" => ["module LogLineParser\n\nlet parse str = 2"] }
      }
    }
    assert_equal expected, doc.except("_version", "_seq_no", "_primary_term")
  end

  test "indexes solution with latest iteration but no published iteration" do
    user = create :user, id: 7, handle: 'jane'
    track = create :track, id: 11, slug: 'fsharp', title: 'F#'
    exercise = create(:practice_exercise, id: 13, slug: 'bob', title: 'Bob', track:)
    solution = create(:practice_solution,
      id: 17,
      num_stars: 3,
      num_loc: 55,
      num_views: 20,
      num_comments: 2,
      user:,
      exercise:)

    submission_1 = create :submission, solution:, tests_status: :failed
    create :submission_file, submission: submission_1, content: "module LogLineParser"
    create :iteration, submission: submission_1

    submission_2 = create :submission, solution:, tests_status: :passed
    create :submission_file, submission: submission_2, content: "module LogLineParser\n\nlet parse str = 2"
    create :iteration, submission: submission_2

    submission_3 = create :submission, solution:, tests_status: :failed
    create :submission_file, submission: submission_3, content: "let parse str = 3"
    create :iteration, submission: submission_3, deleted_at: Time.current

    solution.update!(last_iterated_at: Time.parse("2021-02-22T11:22:33.000Z").utc)

    Solution::SyncToSearchIndex.(solution)

    doc = get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution.id)
    expected = {
      "_index" => "test-solutions",
      "_id" => "17",
      "found" => true,
      "_source" => {
        "id" => 17,
        "last_iterated_at" => "2021-02-22T11:22:33.000Z",
        "published_at" => nil,
        "num_stars" => 3,
        "num_loc" => 55,
        "num_comments" => 2,
        "num_views" => 20,
        "out_of_date" => false,
        "status" => "iterated",
        "mentoring_status" => "none",
        "exercise" => {
          "id" => 13,
          "slug" => "bob",
          "title" => "Bob"
        },
        "track" => { "id" => 11, "slug" => "fsharp", "title" => "F#" },
        "user" => { "id" => 7, "handle" => "jane" },
        "published_iteration" => nil,
        "latest_iteration" => { "tests_status" => "passed", "head_tests_status" => "not_queued",
                                "code" => ["module LogLineParser\n\nlet parse str = 2"] }
      }
    }
    assert_equal expected, doc.except("_version", "_seq_no", "_primary_term")
  end

  test "indexes solution with no latest iteration nor published iteration" do
    user = create :user, id: 7, handle: 'jane'
    track = create :track, id: 11, slug: 'fsharp', title: 'F#'
    exercise = create(:practice_exercise, id: 13, slug: 'bob', title: 'Bob', track:)
    solution = create(:practice_solution,
      id: 17,
      num_stars: 3,
      num_loc: 55,
      num_views: 20,
      num_comments: 2,
      user:,
      exercise:)

    submission_1 = create :submission, solution:, tests_status: :failed
    create :submission_file, submission: submission_1, content: "module LogLineParser"
    create :iteration, submission: submission_1, deleted_at: Time.current

    submission_2 = create :submission, solution:, tests_status: :passed
    create :submission_file, submission: submission_2, content: "module LogLineParser\n\nlet parse str = 2"
    create :iteration, submission: submission_2, deleted_at: Time.current

    solution.update!(last_iterated_at: Time.parse("2021-02-22T11:22:33.000Z").utc)

    Solution::SyncToSearchIndex.(solution)

    doc = get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution.id)
    expected = {
      "_index" => "test-solutions",
      "_id" => "17",
      "found" => true,
      "_source" => {
        "id" => 17,
        "last_iterated_at" => "2021-02-22T11:22:33.000Z",
        "published_at" => nil,
        "num_stars" => 3,
        "num_loc" => 55,
        "num_comments" => 2,
        "num_views" => 20,
        "out_of_date" => false,
        "status" => "iterated",
        "mentoring_status" => "none",
        "exercise" => {
          "id" => 13,
          "slug" => "bob",
          "title" => "Bob"
        },
        "track" => { "id" => 11, "slug" => "fsharp", "title" => "F#" },
        "user" => { "id" => 7, "handle" => "jane" },
        "published_iteration" => nil,
        "latest_iteration" => nil
      }
    }
    assert_equal expected, doc.except("_version", "_seq_no", "_primary_term")
  end

  test "indexes solution with multiple submission files" do
    user = create :user, id: 7, handle: 'jane'
    track = create :track, id: 11, slug: 'fsharp', title: 'F#'
    exercise = create(:practice_exercise, id: 13, slug: 'bob', title: 'Bob', track:)
    solution = create(:practice_solution,
      id: 17,
      num_stars: 3,
      num_loc: 55,
      num_views: 20,
      num_comments: 2,
      user:,
      exercise:)
    submission = create(:submission, solution:)
    create :submission_file, submission:, content: "module LogLineParser"
    create :submission_file, submission:, content: "module Helper"

    iteration = create(:iteration, submission:)
    solution.update!(
      published_iteration: iteration,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      last_iterated_at: Time.parse("2021-02-22T11:22:33.000Z").utc
    )

    Solution::SyncToSearchIndex.(solution)

    doc = get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution.id)
    expected = {
      "_index" => "test-solutions",
      "_id" => "17",
      "found" => true,
      "_source" => {
        "id" => 17,
        "last_iterated_at" => "2021-02-22T11:22:33.000Z",
        "published_at" => "2020-10-17T02:39:37.000Z",
        "num_stars" => 3,
        "num_loc" => 55,
        "num_comments" => 2,
        "num_views" => 20,
        "out_of_date" => false,
        "status" => "published",
        "mentoring_status" => "none",
        "exercise" => {
          "id" => 13,
          "slug" => "bob",
          "title" => "Bob"
        },
        "track" => { "id" => 11, "slug" => "fsharp", "title" => "F#" },
        "user" => { "id" => 7, "handle" => "jane" },
        "published_iteration" => { "tests_status" => "not_queued", "head_tests_status" => "not_queued",
                                   "code" => ["module LogLineParser", "module Helper"] },
        "latest_iteration" => { "tests_status" => "not_queued", "head_tests_status" => "not_queued",
                                "code" => ["module LogLineParser", "module Helper"] }
      }
    }
    assert_equal expected, doc.except("_version", "_seq_no", "_primary_term")
  end

  test "remove solution from index when user is ghost user" do
    user = create :user
    ghost_user = create :user, :ghost
    solution = create(:practice_solution, user:)

    Solution::SyncToSearchIndex.(solution)

    refute_nil get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution.id)

    solution.update(user: ghost_user)
    Solution::SyncToSearchIndex.(solution)

    assert_nil get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution.id)
  end
end
