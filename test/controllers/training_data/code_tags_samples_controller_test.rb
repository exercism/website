require "test_helper"

class TrainingData::CodeTagsSamplesControllerTest < ActionDispatch::IntegrationTest
  test "index: renders when user is trainer" do
    user = create :user, trainer: true
    sign_in!(user)

    get training_data_code_tags_samples_path
    assert_response :ok
  end

  test "index: redirects to external page when user is not trainer" do
    user = create :user
    sign_in!(user)

    get training_data_code_tags_samples_path
    assert_redirected_to training_data_external_path
  end
end
