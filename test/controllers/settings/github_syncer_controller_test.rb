require "test_helper"

class Settings::GithubSyncerControllerTest < ActionDispatch::IntegrationTest
  test "update saves a valid branch name" do
    user = create :user, :insider
    syncer = create(:user_github_solution_syncer, user:)
    sign_in!(user)

    patch settings_github_syncer_path,
      params: { github_solution_syncer: { processing_method: "commit", main_branch_name: "trunk" } },
      as: :json

    assert_response :success
    syncer.reload
    assert_equal "trunk", syncer.main_branch_name
    assert_equal :commit, syncer.processing_method
  end

  test "update returns an error for an invalid branch name" do
    user = create :user, :insider
    syncer = create(:user_github_solution_syncer, user:)
    sign_in!(user)

    patch settings_github_syncer_path,
      params: { github_solution_syncer: { processing_method: "commit", main_branch_name: "my branch" } },
      as: :json

    assert_response :bad_request
    error = response.parsed_body["error"]
    assert_equal "invalid_github_solution_syncer", error["type"]
    assert_equal "Main branch name is invalid", error["message"]

    syncer.reload
    assert_equal "main", syncer.main_branch_name
    assert_equal :pull_request, syncer.processing_method
  end
end
