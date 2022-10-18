require 'test_helper'

class Git::Exercise::ApproachesTest < ActiveSupport::TestCase
  test "approaches" do
    approaches = Git::Exercise::Approaches.new("hamming", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))

    expected = [
      {
        uuid: "23360676-7b7f-4759-b6b6-011ef8f9c420",
        slug: "performance",
        title: "Performance",
        blurb: "Check out this perf!",
        authors: ["erikschierboom"],
        contributors: ["ihid"]
      },
      {
        uuid: "954be92c-a79e-4ed6-bd0f-f4db3c09a668",
        slug: "readability",
        title: "Readability",
        blurb: "This reads well!",
        authors: %w[erikschierboom ihid]
      }
    ]
    assert_equal expected, approaches.approaches
  end

  test "filepaths" do
    approaches = Git::Exercise::Approaches.new("bob", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))

    expected_filepaths = [
      "config.json",
      "introduction.md"
    ]
    assert_equal expected_filepaths, approaches.filepaths
  end

  test "absolute_filepaths" do
    approaches = Git::Exercise::Approaches.new("bob", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))

    expected_filepaths = [
      "exercises/practice/bob/.approaches/config.json",
      "exercises/practice/bob/.approaches/introduction.md"
    ]
    assert_equal expected_filepaths, approaches.absolute_filepaths
  end

  test "introduction_last_modified_at with approaches introduction" do
    approaches = Git::Exercise::Approaches.new("bob", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))

    assert_equal Time.zone.utc_to_local(Time.utc(2022, 9, 29, 13, 46, 54)), approaches.introduction_last_modified_at
  end

  test "introduction_last_modified_at without approaches introduction" do
    approaches = Git::Exercise::Approaches.new(:leap, "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))

    assert_nil approaches.introduction_last_modified_at
  end

  test "introduction_authors" do
    approaches = Git::Exercise::Approaches.new("bob", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))
    assert_equal(["erikschierboom"], approaches.introduction_authors)
  end

  test "introduction_authors for exercise without authors" do
    approaches = Git::Exercise::Approaches.new(:allergies, "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))
    assert_empty(approaches.introduction_authors)
  end

  test "config file path" do
    approaches = Git::Exercise::Approaches.new("bob", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))
    assert_equal('config.json', approaches.config_filepath)
  end

  test "config absolute file path" do
    approaches = Git::Exercise::Approaches.new("bob", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))
    assert_equal('exercises/practice/bob/.approaches/config.json', approaches.config_absolute_filepath)
  end

  test "introduction file path" do
    approaches = Git::Exercise::Approaches.new("bob", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))
    assert_equal('introduction.md', approaches.introduction_filepath)
  end

  test "introduction absolute file path" do
    approaches = Git::Exercise::Approaches.new("bob", "practice", "HEAD",
      repo_url: TestHelpers.git_repo_url("track-with-exercises"))
    assert_equal('exercises/practice/bob/.approaches/introduction.md', approaches.introduction_absolute_filepath)
  end
end
