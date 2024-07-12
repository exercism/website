require "test_helper"

class Git::SyncTrackDocsTest < ActiveSupport::TestCase
  test "creates missing docs" do
    track = create :track, synced_to_git_sha: "d337d99a9cbee14ebd8390d5d1cf86351d604a3a"
    Git::SyncTrackDocs.(track)

    assert_equal 2, Document.count

    doc_1 = Document.first
    assert_equal track, doc_1.track
    assert_equal '7dce5fef-d759-4292-a2b4-ba3ed65f93d7', doc_1.uuid
    assert_equal "testing", doc_1.slug
    assert_equal "docs/TESTS.md", doc_1.git_path
    assert_equal "Running the tests", doc_1.title
    assert_equal "Somewhere over the rainbow, tests run green", doc_1.blurb
    assert_equal 0, doc_1.position

    doc_2 = Document.second
    assert_equal track, doc_2.track
    assert_equal 'ae6b8e1c-538e-4431-89e9-c02640e4c3c5', doc_2.uuid
    assert_equal "learning", doc_2.slug
    assert_equal "docs/LEARNING.md", doc_2.git_path
    assert_equal "How to learn C#", doc_2.title
    assert_equal "An overview of how to get started from scratch with C#", doc_2.blurb
    assert_equal 1, doc_2.position
  end

  test "updates existing docs" do
    track = create :track, synced_to_git_sha: "d337d99a9cbee14ebd8390d5d1cf86351d604a3a"
    create :document, uuid: "7dce5fef-d759-4292-a2b4-ba3ed65f93d7",
      track:,
      slug: "rlly",
      git_path: "incorrect/old.md",
      title: "Very wrong",
      blurb: "Wrong",
      position: 3

    Git::SyncTrackDocs.(track)

    assert_equal 2, Document.count
    doc = Document.first
    assert_equal track, doc.track
    assert_equal '7dce5fef-d759-4292-a2b4-ba3ed65f93d7', doc.uuid
    assert_equal "testing", doc.slug
    assert_equal "docs/TESTS.md", doc.git_path
    assert_equal "Running the tests", doc.title
    assert_equal "Somewhere over the rainbow, tests run green", doc.blurb
    assert_equal 0, doc.position
  end

  test "noop if config.json hasn't changed" do
    track = create :track, synced_to_git_sha: "70714c7d1ac6504c00b8034723da59acb2fb74e7"

    Git::Repository.any_instance.expects(:read_json_blob).never

    Git::SyncTrackDocs.(track)
  end

  test "updates if config.json hasn't changed but force_sync is true" do
    track = create :track, synced_to_git_sha: "5f717d8cfc5f588ddff9b1ea5e605f33e70a5c45"

    Git::SyncTrackDocs.(track, force_sync: true)

    assert_equal 2, Document.count
  end
end
