require 'test_helper'

module Git
  class RepositoryTest < Minitest::Test
    def test_lookup_commit_for_good_commit
      repository = Repository.new(
        :csharp,
        repo_url: TestHelpers.git_repo_url("v3-monorepo")
      )
      assert repository.lookup_commit("88bfc517efcabd63714ee3b1d853d9bf233f4f3b")
    end

    def test_lookup_commit_for_bad_commit
      repository = Repository.new(
        :csharp,
        repo_url: TestHelpers.git_repo_url("v3-monorepo")
      )
      assert_raises do
        repository.lookup_commit("foobar")
      end
    end

    def test_lookup_commit_for_head
      repository = Repository.new(
        :csharp,
        repo_url: TestHelpers.git_repo_url("v3-monorepo")
      )
      assert_equal repository.head_commit, repository.lookup_commit("HEAD")
    end

    def test_read_json_blob_for_valid_path
      repository = Repository.new(
        :csharp,
        repo_url: TestHelpers.git_repo_url("v3-monorepo")
      )
      commit = repository.lookup_commit("HEAD")
      json = repository.read_json_blob(commit, "languages/fsharp/config.json")
      assert_equal "fsharp", json[:slug]
    end

    def test_read_json_blob_for_invalid_path
      repository = Repository.new(
        :csharp,
        repo_url: TestHelpers.git_repo_url("v3-monorepo")
      )
      commit = repository.lookup_commit("HEAD")
      json = repository.read_json_blob(commit, "foobar")
      assert_empty json
    end

    def test_read_text_blob_for_valid_path
      repository = Repository.new(
        :csharp,
        repo_url: TestHelpers.git_repo_url("v3-monorepo")
      )
      commit = repository.lookup_commit("HEAD")
      refute_empty repository.read_text_blob(commit, "languages/fsharp/README.md")
    end

    def test_read_text_blob_for_invalid_path
      repository = Repository.new(
        :csharp,
        repo_url: TestHelpers.git_repo_url("v3-monorepo")
      )
      commit = repository.lookup_commit("HEAD")
      assert_empty repository.read_text_blob(commit, "foobar")
    end
  end
end
