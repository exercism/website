require 'test_helper'

module Git
  class RepositoryTest < ActiveSupport::TestCase
    test "lookup_commit_for_good_commit" do
      repository = ::Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
      assert repository.lookup_commit("51846e21335947fc3bee8cb08e8e0b25378f96cd")
    end

    test "lookup_commit_for_bad_commit" do
      repository = ::Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_raises do
        repository.lookup_commit("foobar")
      end
    end

    test "lookup_commit_for_head" do
      repository = ::Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
      assert_equal repository.head_commit, repository.lookup_commit("HEAD")
    end

    test "read_json_blob_for_valid_path" do
      repository = ::Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
      commit = repository.lookup_commit("HEAD")
      json = repository.read_json_blob(commit, "config.json")
      assert_equal "ruby", json[:slug]
    end

    test "read_json_blob_for_invalid_path" do
      repository = ::Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
      commit = repository.lookup_commit("HEAD")
      json = repository.read_json_blob(commit, "foobar")
      assert_empty json
    end

    test "read_text_blob_for_valid_path" do
      repository = ::Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
      commit = repository.lookup_commit("HEAD")
      refute_empty repository.read_text_blob(commit, "docs/ABOUT.md")
    end

    test "read_text_blob_for_invalid_path" do
      repository = ::Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
      commit = repository.lookup_commit("HEAD")
      assert_empty repository.read_text_blob(commit, "foobar")
    end

    test "file_exists?" do
      repository = ::Git::Repository.new(repo_url: TestHelpers.git_repo_url("track"))
      commit = repository.lookup_commit("HEAD")

      assert repository.file_exists?(commit, "docs/ABOUT.md")
      refute repository.file_exists?(commit, "foobar")
    end
  end
end
