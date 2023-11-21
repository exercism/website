require "test_helper"

class TrainingData::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "index: renders when user is trainer" do
    user = create :user, trainer: true
    sign_in!(user)

    get training_data_root_path
    assert_response :ok
  end

  test "index: redirects to external page when user is not trainer" do
    user = create :user
    sign_in!(user)

    get training_data_root_path
    assert_redirected_to training_data_external_path
  end

  test "index: redirects to external page when user is not logged in" do
    get training_data_root_path
    assert_redirected_to training_data_external_path
  end
end
