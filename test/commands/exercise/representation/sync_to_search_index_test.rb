require "test_helper"

class Exercise::Representation::SyncToSearchIndexTest < ActiveSupport::TestCase
  test "does not index hello world" do
    Exercise::Representation::CreateSearchIndexDocument.stubs(:call).returns("")

    hello_world = create :hello_world_exercise

    representation = create(
      :exercise_representation,
      exercise: hello_world,
      num_published_solutions: 5
    )

    OpenSearch::Client.any_instance.expects(:index).never
    Exercise::Representation::SyncToSearchIndex.(representation)

    # Assert works if it's not hello-world
    representation.update!(exercise: create(:practice_exercise))
    OpenSearch::Client.any_instance.expects(:index)
    Exercise::Representation::SyncToSearchIndex.(representation)
  end

  test "indexes representation" do
    track = create :track, id: 11, slug: 'fsharp', title: 'F#'
    exercise = create(:practice_exercise, id: 13, slug: 'bob', title: 'Bob', track:)
    content = "module LogLineParser"
    num_published_solutions = 20
    num_loc = 42

    solutions = Array.new(2).map do
      create(:practice_solution, :published, published_iteration_head_tests_status: :passed).tap do |solution|
        submission = create(:submission, solution:)
        create(:iteration, submission:)
      end
    end

    oldest_solution = solutions.first
    oldest_solution.update(num_loc:)
    prestigious_solution = solutions.second
    prestigious_solution.user.update(reputation: 1234)
    create :user_arbitrary_reputation_token, user: prestigious_solution.user, track: exercise.track,
      params: { arbitrary_value: 20, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user: prestigious_solution.user, track: exercise.track,
      params: { arbitrary_value: 50, arbitrary_reason: "" }

    source_submission = create(:submission)
    create(:submission_file, submission: source_submission, content:)

    representation = create(
      :exercise_representation,
      exercise:,
      num_published_solutions:,
      source_submission:,
      oldest_solution:,
      prestigious_solution:
    )

    Exercise::Representation::SyncToSearchIndex.(representation)

    doc = get_opensearch_doc(Exercise::Representation::OPENSEARCH_INDEX, representation.id)
    expected = {
      "_index" => "test-exercise-representation",
      "_id" => representation.id.to_s,
      "found" => true,
      "_source" => {
        "id" => representation.id,
        "oldest_solution_id" => oldest_solution.id,
        "prestigious_solution_id" => prestigious_solution.id,
        "num_loc" => num_loc,
        "num_solutions" => num_published_solutions,
        "max_reputation" => 20 + 50,
        "tags" => [],
        "code" => ["module LogLineParser"],
        "exercise" => { "id" => 13, "slug" => "bob", "title" => "Bob" },
        "track" => { "id" => 11, "slug" => "fsharp", "title" => "F#" }
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
