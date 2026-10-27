require "test_helper"

class User::GithubSolutionSyncerTest < ActiveSupport::TestCase
  test "accepts typical branch names" do
    syncer = create(:user_github_solution_syncer)

    %w[main master trunk develop release/v1.2 feature/my_branch iHiD-solutions a].each do |name|
      syncer.main_branch_name = name
      assert syncer.valid?, "Expected #{name.inspect} to be valid"
    end
  end

  test "rejects branch names git would refuse or that we don't support" do
    syncer = create(:user_github_solution_syncer)

    [
      "",
      " ",
      "my branch",
      "-main",
      "/main",
      "main/",
      "main.",
      ".main",
      "feature/.main",
      "main..dev",
      "feature//main",
      "main.lock",
      "feature.lock/main",
      "main~1",
      "main^",
      "main:dev",
      "main?",
      "main*",
      "main[1]",
      "main\\dev",
      "main@{1}",
      "main;dev",
      "main$dev",
      "main`dev`",
      "main|dev",
      "main&dev",
      "main\ndev",
      "mäin",
      "a" * 101
    ].each do |name|
      syncer.main_branch_name = name
      refute syncer.valid?, "Expected #{name.inspect} to be invalid"
      assert_includes syncer.errors[:main_branch_name], "is invalid"
    end
  end

  test "accepts a branch name at the maximum length" do
    syncer = create(:user_github_solution_syncer)
    syncer.main_branch_name = "a" * 100

    assert syncer.valid?
  end

  test "defaults to main" do
    assert_equal "main", create(:user_github_solution_syncer).main_branch_name
  end
end
