require "test_helper"

class Solution::SyncAllToSearchIndexTest < ActiveSupport::TestCase
  test "indexes all solutions" do
    Solution::QueueHeadTestRun.stubs(:defer)

    track = create :track
    users = build_list(:user, 10)
    exercises = build_list(:practice_exercise, 20, :random_slug, track:)

    exercises.product(users).each do |(exercise, user)|
      solution = create(:practice_solution, user:, exercise:)
      submission = create(:submission, solution:)
      create :submission_file, submission:, content: "module LogLineParser"
      create :iteration, submission:
    end

    wait_for_opensearch_to_be_synced

    Solution::SyncAllToSearchIndex.()

    wait_for_opensearch_to_be_synced

    counts = Exercism.opensearch_client.count(index: Solution::OPENSEARCH_INDEX)
    assert 200, counts["counts"]
  end

  test "indexes solution using correct information" do
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
      published_iteration_head_tests_status: :not_queued
    submission = create(:submission, solution:)
    create :submission_file, submission:, content: "module LogLineParser"
    iteration = create(:iteration, submission:)

    solution.update!(
      published_iteration: iteration,
      published_at: Time.parse("2020-10-17T02:39:37.000Z").utc,
      last_iterated_at: Time.parse("2021-02-22T11:22:33.000Z").utc
    )

    Solution::SyncAllToSearchIndex.()

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
                                   "code" => ["module LogLineParser"] },
        "latest_iteration" => { "tests_status" => "not_queued", "head_tests_status" => "not_queued",
                                "code" => ["module LogLineParser"] }
      }
    }
    assert_equal expected, doc.except("_version", "_seq_no", "_primary_term")
  end
end
