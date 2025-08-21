require "test_helper"

class Git::SyncMainDocsTest < ActiveSupport::TestCase
  test "creates missing docs" do
    TestHelpers.use_docs_test_repo!

    Git::SyncMainDocs.()

    assert_equal 2, Document.count

    doc_1 = Document.first
    assert_nil doc_1.track
    assert_equal '7c7139b9-a228-4691-a4e4-a0c39a6dd615', doc_1.uuid
    assert_equal "building", doc_1.section
    assert_equal "APEX", doc_1.slug
    assert_equal "contributing/README.md", doc_1.git_path
    assert_equal "Contributing to Exercism", doc_1.title
    assert_equal "An overview of how to contribute to Exercism", doc_1.blurb
    assert_equal 0, doc_1.position

    doc_2 = Document.second
    assert_nil doc_2.track
    assert_equal 'd372e903-31fa-4918-a506-e3f939452828', doc_2.uuid
    assert_equal "building", doc_2.section
    assert_equal "configlet", doc_2.slug
    assert_equal "building/configlet/README.md", doc_2.git_path
    assert_equal "Configlet", doc_2.title
    assert_equal "The canonical specifications for everything on Exercism", doc_2.blurb
    assert_equal 1, doc_2.position
  end

  test "updates existing docs" do
    TestHelpers.use_docs_test_repo!

    create :document, uuid: "7c7139b9-a228-4691-a4e4-a0c39a6dd615",
      slug: "rlly",
      git_path: "incorrect/old.md",
      title: "Very wrong",
      blurb: "Wrong",
      position: 3

    Git::SyncMainDocs.()

    assert_equal 2, Document.count
    doc = Document.first
    assert_equal '7c7139b9-a228-4691-a4e4-a0c39a6dd615', doc.uuid
    assert_equal "building", doc.section
    assert_equal "APEX", doc.slug
    assert_equal "contributing/README.md", doc.git_path
    assert_equal "Contributing to Exercism", doc.title
    assert_equal "An overview of how to contribute to Exercism", doc.blurb
    assert_equal 0, doc.position
  end

  test "open issue for sync failure when not synced successfully" do
    TestHelpers.use_docs_test_repo!

    repo_url = TestHelpers.git_repo_url("docs")
    repo = Git::Repository.new(repo_url:)

    error = StandardError.new "Could not find Concept X"
    Document.any_instance.stubs(:update!).raises(error)

    document_1 = {
      uuid: "7c7139b9-a228-4691-a4e4-a0c39a6dd615",
      section: "contributing",
      slug: "APEX",
      path: "contributing/README.md",
      title: "Contributing to Exercism",
      blurb: "An overview of how to contribute to Exercism"
    }
    Github::Issue::OpenForDocSyncFailure.expects(:call).with(document_1, :building, error, repo.head_commit.oid)

    document_2 = {
      uuid: "d372e903-31fa-4918-a506-e3f939452828",
      slug: "configlet",
      path: "building/configlet/README.md",
      title: "Configlet",
      blurb: "The canonical specifications for everything on Exercism"
    }
    Github::Issue::OpenForDocSyncFailure.expects(:call).with(document_2, :building, error, repo.head_commit.oid)

    Git::SyncMainDocs.()
  end
end
