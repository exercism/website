require "test_helper"

class Git::SyncMainDocsTest < ActiveSupport::TestCase
  test "creates missing docs" do
    TestHelpers.use_docs_test_repo!

    Git::SyncMainDocs.()

    assert_equal 1, Document.count
    doc = Document.first
    assert_nil doc.track
    assert_equal '7c7139b9-a228-4691-a4e4-a0c39a6dd615', doc.uuid
    assert_equal "building", doc.section
    assert_equal "APEX", doc.slug
    assert_equal "contributing/README.md", doc.git_path
    assert_equal "Contributing to Exercism", doc.title
    assert_equal "An overview of how to contribute to Exercism", doc.blurb
  end

  test "updates existing docs" do
    TestHelpers.use_docs_test_repo!

    create :document, uuid: "7c7139b9-a228-4691-a4e4-a0c39a6dd615",
      slug: "rlly",
      git_path: "incorrect/old.md",
      title: "Very wrong",
      blurb: "Wrong"

    Git::SyncMainDocs.()

    assert_equal 1, Document.count
    doc = Document.first
    assert_equal '7c7139b9-a228-4691-a4e4-a0c39a6dd615', doc.uuid
    assert_equal "building", doc.section
    assert_equal "APEX", doc.slug
    assert_equal "contributing/README.md", doc.git_path
    assert_equal "Contributing to Exercism", doc.title
    assert_equal "An overview of how to contribute to Exercism", doc.blurb
  end

  test "open issue for sync failure when not synced successfully" do
    TestHelpers.use_docs_test_repo!

    repo_url = TestHelpers.git_repo_url("docs")
    repo = Git::Repository.new(repo_url:)

    error = StandardError.new "Could not find Concept X"
    Document.any_instance.stubs(:update!).raises(error)

    document = {
      uuid: "7c7139b9-a228-4691-a4e4-a0c39a6dd615",
      section: "contributing",
      slug: "APEX",
      path: "contributing/README.md",
      title: "Contributing to Exercism",
      blurb: "An overview of how to contribute to Exercism"
    }

    Github::Issue::OpenForDocSyncFailure.expects(:call).with(document, :building, error, repo.head_commit.oid)

    Git::SyncMainDocs.()
  end
end
