require "test_helper"

class TrainingData::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "index: redirects to code tags samples" do
    user = create :user, trainer: true
    sign_in!(user)

    get training_data_root_path
    assert_redirected_to training_data_code_tags_samples_path
  end
end
