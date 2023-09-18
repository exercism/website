require "test_helper"

class Document::SearchDocsTest < ActiveSupport::TestCase
  test "no options returns everything" do
    doc_1 = create :document
    doc_2 = create :document

    # Sanity check: ensure that the results are not returned using the fallback
    Document::SearchDocs::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [doc_1, doc_2], Document::SearchDocs.()
  end

  test "criteria" do
    ruby = create :track, title: "Ruby", slug: "ruby"
    elixir = create :track, title: "Elixir", slug: 'elixir'

    non_track_doc = create :document, track: nil, title: 'Feedback', blurb: 'Give and receive'
    ruby_doc_1 = create :document, track: ruby, title: 'Installation', blurb: 'Step by step'
    ruby_doc_2 = create :document, track: ruby, title: 'Learning', blurb: 'How to learn resources'
    elixir_doc = create :document, track: elixir, title: 'Resources', blurb: 'Links to documents'

    # Sanity check: ensure that the results are not returned using the fallback
    Document::SearchDocs::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

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

    wait_for_opensearch_to_be_synced

    assert_equal [non_track_doc, ruby_doc_1, ruby_doc_2, elixir_doc], Document::SearchDocs.()
    assert_equal [non_track_doc, ruby_doc_1, ruby_doc_2, elixir_doc], Document::SearchDocs.(criteria: " ") # :LineLength
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

    wait_for_opensearch_to_be_synced

    # We need to manually re-sync as markdown isn't a DB column and the indexing
    # is started automatically when a Document record is saved (before the stub is setup)
    matching_title.stubs(:markdown).returns('Markdown 1')
    matching_blurb.stubs(:markdown).returns('Markdown 2')
    matching_markdown.stubs(:markdown).returns('Install')
    Document::SyncToSearchIndex.(matching_title)
    Document::SyncToSearchIndex.(matching_blurb)
    Document::SyncToSearchIndex.(matching_markdown)

    wait_for_opensearch_to_be_synced

    # We've setup the document to have the "Install" text in different properties (title/blurb/markdown)
    # to verify that the right boosting is applied
    assert_equal [matching_title, matching_blurb, matching_markdown], Document::SearchDocs.(criteria: "install")
  end

  test "track_slug" do
    ruby = create :track, title: "Ruby", slug: "ruby"
    elixir = create :track, title: "Elixir", slug: 'elixir'
    common_lisp = create :track, title: "Common Lisp", slug: 'common-lisp'

    # Sanity check: non track doc should not be included
    non_track_doc = create :document, track: nil

    ruby_doc_1 = create :document, track: ruby
    ruby_doc_2 = create :document, track: ruby
    elixir_doc = create :document, track: elixir
    common_lisp_doc = create :document, track: common_lisp

    # Sanity check: ensure that the results are not returned using the fallback
    Document::SearchDocs::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [non_track_doc, ruby_doc_1, ruby_doc_2, elixir_doc, common_lisp_doc], Document::SearchDocs.()
    assert_equal [ruby_doc_1, ruby_doc_2, elixir_doc], Document::SearchDocs.(track_slug: %i[ruby elixir])
    assert_equal [ruby_doc_1, ruby_doc_2], Document::SearchDocs.(track_slug: "ruby")
    assert_equal [common_lisp_doc], Document::SearchDocs.(track_slug: "common-lisp")
  end

  test "pagination" do
    doc_1 = create :document
    doc_2 = create :document
    doc_3 = create :document

    # Sanity check: ensure that the results are not returned using the fallback
    Document::SearchDocs::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [doc_1], Document::SearchDocs.(page: 1, per: 1)
    assert_equal [doc_2], Document::SearchDocs.(page: 2, per: 1)
    assert_equal [doc_3], Document::SearchDocs.(page: 3, per: 1)
    assert_equal [doc_1, doc_2], Document::SearchDocs.(page: 1, per: 2)
    assert_empty Document::SearchDocs.(page: 3, per: 2)
  end

  test "pagination with invalid values" do
    doc_1 = create :document
    doc_2 = create :document
    doc_3 = create :document

    # Sanity check: ensure that the results are not returned using the fallback
    Document::SearchDocs::Fallback.expects(:call).never

    wait_for_opensearch_to_be_synced

    assert_equal [doc_1, doc_2, doc_3], Document::SearchDocs.(page: 0, per: 0)
    assert_equal [doc_1, doc_2, doc_3], Document::SearchDocs.(page: 'foo', per: 'bar')
  end

  test "fallback is called" do
    Document::SearchDocs::Fallback.expects(:call).with("foobar", "csharp", 2, 15)
    OpenSearch::Client.expects(:new).raises

    Document::SearchDocs.(criteria: "foobar", track_slug: "csharp", page: 2, per: 15)
  end

  test "fallback is called when OpenSearch times out" do
    # Simulate a timeout
    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Document::SearchDocs.any_instance.stubs(:search_query).returns({
        query: {
          function_score: {
            script_score: {
              script: {
                lang: "painless",
                source: "long total = 0; for (int i = 0; i < 500000; ++i) { total += i; } return total;"
              }
            }
          }
        }
      })
    end

    Document::SearchDocs::Fallback.expects(:call).with(nil, nil, 1, 25)

    Document::SearchDocs.()
  end

  test "fallback: no options returns everything" do
    doc_1 = create :document
    doc_2 = create :document

    assert_equal [doc_1, doc_2], Document::SearchDocs::Fallback.(nil, nil, 1, 15)
  end

  test "fallback: criteria" do
    ruby = create :track, title: "Ruby", slug: "ruby"
    elixir = create :track, title: "Elixir", slug: 'elixir'

    non_track_doc = create :document, track: nil, title: 'Feedback', blurb: 'Give and receive'
    ruby_doc_1 = create :document, track: ruby, title: 'Installation', blurb: 'Step by step'
    ruby_doc_2 = create :document, track: ruby, title: 'Learning', blurb: 'How to learn resources'
    elixir_doc = create :document, track: elixir, title: 'Resources', blurb: 'Links to documents'

    assert_equal [non_track_doc, ruby_doc_1, ruby_doc_2, elixir_doc], Document::SearchDocs::Fallback.(nil, nil, 1, 15)
    assert_equal [non_track_doc, ruby_doc_1, ruby_doc_2, elixir_doc], Document::SearchDocs::Fallback.(" ", nil, 1, 15)
    assert_equal [ruby_doc_1], Document::SearchDocs::Fallback.("install", nil, 1, 15)
    assert_equal [ruby_doc_1], Document::SearchDocs::Fallback.("inst step", nil, 1, 15)
    assert_equal [ruby_doc_2, elixir_doc], Document::SearchDocs::Fallback.("resources", nil, 1, 15)
  end

  test "fallback: track_slug" do
    ruby = create :track, title: "Ruby", slug: "ruby"
    elixir = create :track, title: "Elixir", slug: 'elixir'

    # Sanity check: non track doc should not be included
    non_track_doc = create :document, track: nil

    ruby_doc_1 = create :document, track: ruby
    ruby_doc_2 = create :document, track: ruby
    elixir_doc = create :document, track: elixir

    assert_equal [non_track_doc, ruby_doc_1, ruby_doc_2, elixir_doc], Document::SearchDocs::Fallback.(nil, nil, 1, 15)
    assert_equal [ruby_doc_1, ruby_doc_2, elixir_doc], Document::SearchDocs::Fallback.(nil, %i[ruby elixir], 1, 15)
    assert_equal [ruby_doc_1, ruby_doc_2], Document::SearchDocs::Fallback.(nil, "ruby", 1, 15)
  end

  test "fallback: pagination" do
    doc_1 = create :document
    doc_2 = create :document
    doc_3 = create :document

    assert_equal [doc_1], Document::SearchDocs::Fallback.(nil, nil, 1, 1)
    assert_equal [doc_2], Document::SearchDocs::Fallback.(nil, nil, 2, 1)
    assert_equal [doc_1, doc_2], Document::SearchDocs::Fallback.(nil, nil, 1, 2)
    assert_equal [doc_3], Document::SearchDocs::Fallback.(nil, nil, 2, 2)
    assert_empty Document::SearchDocs::Fallback.(nil, nil, 3, 2)
  end
end
