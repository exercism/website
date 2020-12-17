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
  end
end
