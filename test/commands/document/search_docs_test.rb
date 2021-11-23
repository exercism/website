require "test_helper"

class Document::SearchDocsTest < ActiveSupport::TestCase
  setup do
    reset_opensearch!(Document::OPENSEARCH_INDEX)
  end

  test "no options returns everything" do
    doc_1 = create :document
    doc_2 = create :document

    # Sanity check: ensure that the results are not returned using the fallback
    Document::SearchDocs::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)

    assert_equal [doc_2, doc_1], Document::SearchDocs.()
  end

  test "criteria" do
    ruby = create :track, title: "Ruby", slug: "ruby"
    elixir = create :track, title: "Elixir", slug: 'elixir'

    # Sanity check: non track doc should not be included
    non_track_doc = create :document, track: nil, title: 'Feedback', blurb: 'Give and receive'
    ruby_doc_1 = create :document, track: ruby, title: 'Installation', blurb: 'Step by step'
    ruby_doc_2 = create :document, track: ruby, title: 'Learning', blurb: 'How to learn resources'
    elixir_doc = create :document, track: elixir, title: 'Resources', blurb: 'Links to documents'

    # Sanity check: ensure that the results are not returned using the fallback
    Document::SearchDocs::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)

    # We need to manually re-sync as markdown isn't a DB column and the indexing
    # is started automatically when a Document record is saved (before the stub is setup)
    non_track_doc.stubs(:markdown).returns('# Response')
    ruby_doc_1.stubs(:markdown).returns('Instructions to install')
    ruby_doc_2.stubs(:markdown).returns('## Guides')
    elixir_doc.stubs(:markdown).returns('Great links')
    Document::SyncToSearchIndex.(non_track_doc)
    Document::SyncToSearchIndex.(ruby_doc_1)
    Document::SyncToSearchIndex.(ruby_doc_2)
    Document::SyncToSearchIndex.(elixir_doc)

    assert_equal [elixir_doc, ruby_doc_2, ruby_doc_1, non_track_doc], Document::SearchDocs.()
    assert_equal [elixir_doc, ruby_doc_2, ruby_doc_1, non_track_doc], Document::SearchDocs.(criteria: " ") # rubocop:disable Layout:LineLength
    assert_equal [ruby_doc_1], Document::SearchDocs.(criteria: "install")
    assert_equal [ruby_doc_1], Document::SearchDocs.(criteria: "inst step")
    assert_equal [elixir_doc, ruby_doc_2], Document::SearchDocs.(criteria: "resources")
  end

  test "criteria boosted" do
    matching_title = create :document, title: 'Install', blurb: 'Blurb 1'
    matching_blurb = create :document, title: 'Title 2', blurb: 'Install'
    matching_markdown = create :document, title: 'Title 3', blurb: 'Blurb 3'

    # Sanity check: ensure that the results are not returned using the fallback
    Document::SearchDocs::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)

    # We need to manually re-sync as markdown isn't a DB column and the indexing
    # is started automatically when a Document record is saved (before the stub is setup)
    matching_title.stubs(:markdown).returns('Markdown 1')
    matching_blurb.stubs(:markdown).returns('Markdown 2')
    matching_markdown.stubs(:markdown).returns('Install')
    Document::SyncToSearchIndex.(matching_title)
    Document::SyncToSearchIndex.(matching_blurb)
    Document::SyncToSearchIndex.(matching_markdown)

    # We've setup the document to have the "Install" text in different properties (title/blurb/markdown)
    # to verify that the right boosting is applied
    assert_equal [matching_title, matching_blurb, matching_markdown], Document::SearchDocs.(criteria: "install")
  end

  test "track_slug" do
    ruby = create :track, title: "Ruby", slug: "ruby"
    elixir = create :track, title: "Elixir", slug: 'elixir'

    # Sanity check: non track doc should not be included
    non_track_doc = create :document, track: nil

    ruby_doc_1 = create :document, track: ruby
    ruby_doc_2 = create :document, track: ruby
    elixir_doc = create :document, track: elixir

    # Sanity check: ensure that the results are not returned using the fallback
    Document::SearchDocs::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)

    assert_equal [elixir_doc, ruby_doc_2, ruby_doc_1, non_track_doc], Document::SearchDocs.()
    assert_equal [elixir_doc, ruby_doc_2, ruby_doc_1], Document::SearchDocs.(track_slug: %i[ruby elixir])
    assert_equal [ruby_doc_2, ruby_doc_1], Document::SearchDocs.(track_slug: "ruby")
  end

  #   test "pagination" do
  #     user = create :user
  #     solution_1 = create :concept_solution, user: user
  #     solution_2 = create :concept_solution, user: user

  #     # Sanity check: ensure that the results are not returned using the fallback
  #     Document::SearchDocs::Fallback.expects(:call).never

  #     wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)

  #     assert_equal [solution_2], Document::SearchDocs.(user, page: 1, per: 1)
  #     assert_equal [solution_1], Document::SearchDocs.(user, page: 2, per: 1)
  #     assert_equal [solution_2, solution_1], Document::SearchDocs.(user, page: 1, per: 2)
  #     assert_empty Document::SearchDocs.(user, page: 2, per: 2)
  #   end

  #   test "pagination with invalid values" do
  #     user = create :user
  #     solution_1 = create :concept_solution, user: user
  #     solution_2 = create :concept_solution, user: user

  #     # Sanity check: ensure that the results are not returned using the fallback
  #     Document::SearchDocs::Fallback.expects(:call).never

  #     wait_for_opensearch_to_be_synced(Document::OPENSEARCH_INDEX)

  #     assert_equal [solution_2, solution_1], Document::SearchDocs.(user, page: 0, per: 0)
  #     assert_equal [solution_2, solution_1], Document::SearchDocs.(user, page: 'foo', per: 'bar')
  #   end

  #   test "fallback is called" do
  #     user = create :user
  #     Document::SearchDocs::Fallback.expects(:call).with(user, 2, 15, "csharp", "published", "none", "foobar", "oldest_first")
  #     Elasticsearch::Client.expects(:new).raises

  #     Document::SearchDocs.(user, page: 2, per: 15, track_slug: "csharp", status: "published", mentoring_status: "none",
  # criteria: "foobar", order: "oldest_first")
  #   end

  #   test "fallback: no options returns everything" do
  #     user = create :user
  #     solution_1 = create :concept_solution, user: user
  #     solution_2 = create :practice_solution, user: user

  #     # Someone else's solution
  #     create :concept_solution

  #     assert_equal [solution_2, solution_1], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, nil, nil)
  #   end

  #   test "fallback: criteria" do
  #     user = create :user
  #     javascript = create :track, title: "JavaScript", slug: "javascript"
  #     ruby = create :track, title: "Ruby"
  #     js_bob = create :concept_exercise, title: "Bob", track: javascript
  #     ruby_food = create :concept_exercise, title: "Food Chain", track: ruby
  #     ruby_bob = create :concept_exercise, title: "Bob", track: ruby

  #     js_bob_solution = create :practice_solution, user: user, exercise: js_bob
  #     ruby_food_solution = create :concept_solution, user: user, exercise: ruby_food
  #     ruby_bob_solution = create :concept_solution, user: user, exercise: ruby_bob

  #     assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution],
  #       Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, nil, nil)
  #     assert_equal [ruby_bob_solution, ruby_food_solution, js_bob_solution], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, " ", nil) # rubocop:disable Layout:LineLength
  #     assert_equal [ruby_bob_solution, ruby_food_solution],
  #       Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, "ru", nil)
  #     assert_equal [ruby_bob_solution, js_bob_solution], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, "bo", nil)
  #     assert_equal [ruby_bob_solution].map(&:track),
  #       Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, "ru bo", nil).map(&:track)
  #     assert_equal [ruby_food_solution], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, "r ch fo", nil)
  #   end

  #   test "fallback: track_slug" do
  #     user = create :user
  #     javascript = create :track, title: "JavaScript", slug: "javascript"
  #     ruby = create :track, title: "Ruby", slug: "ruby"
  #     elixir = create :track, title: "Elixir", slug: 'elixir'
  #     ruby_exercise = create :practice_exercise, track: ruby
  #     js_exercise = create :practice_exercise, track: javascript
  #     elixir_exercise = create :practice_exercise, track: elixir

  #     ruby_solution = create :practice_solution, user: user, exercise: ruby_exercise
  #     js_solution = create :practice_solution, user: user, exercise: js_exercise
  #     elixir_solution = create :practice_solution, user: user, exercise: elixir_exercise

  #     assert_equal [elixir_solution, js_solution, ruby_solution],
  #       Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, nil, nil)
  #     assert_equal [js_solution, ruby_solution],
  #       Document::SearchDocs::Fallback.(user, 1, 15, %i[ruby javascript], nil, nil, nil, nil)
  #     assert_equal [ruby_solution], Document::SearchDocs::Fallback.(user, 1, 15, "ruby", nil, nil, nil, nil)
  #   end

  #   test "fallback: status" do
  #     user = create :user
  #     published = create :practice_solution, user: user, status: :published
  #     completed = create :practice_solution, user: user, status: :completed
  #     iterated = create :concept_solution, user: user, status: :iterated

  #     assert_equal [iterated, completed, published], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, nil, nil)
  #     assert_equal [iterated], Document::SearchDocs::Fallback.(user, 1, 15, nil, :iterated, nil, nil, nil)
  #     assert_equal [iterated], Document::SearchDocs::Fallback.(user, 1, 15, nil, 'iterated', nil, nil, nil)
  #     assert_equal [completed, published],
  #       Document::SearchDocs::Fallback.(user, 1, 15, nil, %i[completed published], nil, nil, nil)
  #     assert_equal [completed, published],
  #       Document::SearchDocs::Fallback.(user, 1, 15, nil, %w[completed published], nil, nil, nil)
  #     assert_equal [published], Document::SearchDocs::Fallback.(user, 1, 15, nil, :published, nil, nil, nil)
  #     assert_equal [published], Document::SearchDocs::Fallback.(user, 1, 15, nil, 'published', nil, nil, nil)
  #   end

  #   test "fallback: mentoring_status" do
  #     user = create :user
  #     finished = create :concept_solution, user: user, mentoring_status: :finished
  #     in_progress = create :concept_solution, user: user, mentoring_status: :in_progress
  #     requested = create :concept_solution, user: user, mentoring_status: :requested
  #     none = create :concept_solution, user: user, mentoring_status: :none

  #     assert_equal [none, requested, in_progress, finished],
  #       Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, nil, nil)

  #     assert_equal [none], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, :none, nil, nil)
  #     assert_equal [none], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, 'none', nil, nil)

  #     assert_equal [requested], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, :requested, nil, nil)
  #     assert_equal [requested], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, 'requested', nil, nil)

  #     assert_equal [in_progress], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, :in_progress, nil, nil)
  #     assert_equal [in_progress], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, 'in_progress', nil, nil)

  #     assert_equal [finished], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, :finished, nil, nil)
  #     assert_equal [finished], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, 'finished', nil, nil)

  #     assert_equal [none, finished], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, [:none, 'finished'], nil, nil)
  #   end

  #   test "fallback: pagination" do
  #     user = create :user
  #     solution_1 = create :concept_solution, user: user
  #     solution_2 = create :concept_solution, user: user

  #     assert_equal [solution_2], Document::SearchDocs::Fallback.(user, 1, 1, nil, nil, nil, nil, nil)
  #     assert_equal [solution_1], Document::SearchDocs::Fallback.(user, 2, 1, nil, nil, nil, nil, nil)
  #     assert_equal [solution_2, solution_1], Document::SearchDocs::Fallback.(user, 1, 2, nil, nil, nil, nil, nil)
  #     assert_empty Document::SearchDocs::Fallback.(user, 2, 2, nil, nil, nil, nil, nil)
  #   end

  #   test "fallback: sort oldest first" do
  #     user = create :user
  #     old_solution = create :concept_solution, user: user
  #     new_solution = create :concept_solution, user: user

  #     assert_equal [old_solution, new_solution],
  #       Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, nil, "oldest_first")
  #   end

  #   test "fallback: sort newest first by default" do
  #     user = create :user
  #     old_solution = create :concept_solution, user: user
  #     new_solution = create :concept_solution, user: user

  #     assert_equal [new_solution, old_solution], Document::SearchDocs::Fallback.(user, 1, 15, nil, nil, nil, nil, nil)
  #   end
end
