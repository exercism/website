require "test_helper"

class Exercise::Representation::SyncToSearchIndexTest < ActiveSupport::TestCase
  test "indexes representation" do
    skip
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

  test "remove representation from index when it has no published_solutions" do
    representation = create(:exercise_representation, num_published_solutions: 1)
    create :practice_solution, published_exercise_representation: representation

    document = mock
    Exercise::Representation::CreateSearchIndexDocument.stubs(:call).returns(document)

    OpenSearch::Client.any_instance.expects(:index).with(
      index: Exercise::Representation::OPENSEARCH_INDEX,
      id: representation.id,
      body: document
    )
    Exercise::Representation::SyncToSearchIndex.(representation)

    representation.update!(num_published_solutions: 0)
    OpenSearch::Client.any_instance.expects(:delete).with(
      index: Exercise::Representation::OPENSEARCH_INDEX,
      id: representation.id
    )
    Exercise::Representation::SyncToSearchIndex.(representation)
  end

  test "remove representation from index if its not got a solution" do
    representation = create(:exercise_representation, num_published_solutions: 0)

    OpenSearch::Client.any_instance.expects(:delete).with(
      index: Exercise::Representation::OPENSEARCH_INDEX,
      id: representation.id
    )
    Exercise::Representation::SyncToSearchIndex.(representation)
  end
end
