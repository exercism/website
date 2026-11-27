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
    expected = "The main branch name must be a valid Git branch name of up to 100 characters, " \
               "using only letters, numbers, dots, dashes, underscores and slashes."
    assert_equal expected, error["message"]

    syncer.reload
    assert_equal "main", syncer.main_branch_name
    assert_equal :pull_request, syncer.processing_method
  end

  test "callback shows the error on the settings page when connecting fails" do
    user = create :user
    sign_in!(user)

    User::GithubSolutionSyncer::Create.expects(:call).with(user, "123").
      raises(GithubSolutionSyncerCreationError, "We could not find that GitHub installation.")

    get callback_settings_github_syncer_path(installation_id: "123")
    assert_redirected_to settings_github_syncer_path

    follow_redirect!
    assert_response :success
    assert_select ".c-flash [class~=\"--alert\"]", text: "We could not find that GitHub installation."
  end

  test "callback shows an error on the settings page when the installation id is missing" do
    user = create :user
    sign_in!(user)

    get callback_settings_github_syncer_path
    assert_redirected_to settings_github_syncer_path

    follow_redirect!
    assert_select ".c-flash [class~=\"--alert\"]", text: I18n.t("settings.github_syncer.callback.missing_installation_id")
  end
end
