require "test_helper"

class Git::SyncTrackDocsTest < ActiveSupport::TestCase
  test "creates missing docs" do
    track = create :track, synced_to_git_sha: "d337d99a9cbee14ebd8390d5d1cf86351d604a3a"
    Git::SyncTrackDocs.(track)

    assert_equal 1, Document.count
    doc = Document.first
    assert_equal track, doc.track
    assert_equal '7dce5fef-d759-4292-a2b4-ba3ed65f93d7', doc.uuid
    assert_equal "testing", doc.slug
    assert_equal "docs/TESTS.md", doc.git_path
    assert_equal "Running the tests", doc.title
    assert_equal "Somewhere over the rainbow, tests run green", doc.blurb
  end

  test "updates existing docs" do
    track = create :track, synced_to_git_sha: "d337d99a9cbee14ebd8390d5d1cf86351d604a3a"
    create :document, uuid: "7dce5fef-d759-4292-a2b4-ba3ed65f93d7",
      track:,
      slug: "rlly",
      git_path: "incorrect/old.md",
      title: "Very wrong",
      blurb: "Wrong"

    Git::SyncTrackDocs.(track)

    assert_equal 1, Document.count
    doc = Document.first
    assert_equal track, doc.track
    assert_equal '7dce5fef-d759-4292-a2b4-ba3ed65f93d7', doc.uuid
    assert_equal "testing", doc.slug
    assert_equal "docs/TESTS.md", doc.git_path
    assert_equal "Running the tests", doc.title
    assert_equal "Somewhere over the rainbow, tests run green", doc.blurb
  end

  test "noop if config.json hasn't changed" do
    track = create :track, synced_to_git_sha: "5f717d8cfc5f588ddff9b1ea5e605f33e70a5c45"

    Git::Repository.any_instance.expects(:read_json_blob).never

    Git::SyncTrackDocs.(track)
  end

  test "updates if config.json hasn't changed but force_sync is true" do
    track = create :track, synced_to_git_sha: "5f717d8cfc5f588ddff9b1ea5e605f33e70a5c45"

    Git::SyncTrackDocs.(track, force_sync: true)

    assert_equal 1, Document.count
  end
end
