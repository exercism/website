require "test_helper"

class TrainingData::ExternalControllerTest < ActionDispatch::IntegrationTest
  test "index: renders when not logged in" do
    get training_data_external_path
    assert_response :ok
  end

  test "index: renders when user is not trainer in" do
    user = create :user
    sign_in!(user)

    get training_data_external_path
    assert_response :ok
  end

  test "index: redirects to training data when user is trainer in" do
    user = create :user, trainer: true
    sign_in!(user)

    get training_data_external_path
    assert_redirected_to training_data_root_path
  end

  test "become_trainer: makes user trainer when user is logged in" do
    user = create :user
    sign_in!(user)
    User::BecomeTrainer.expects(:call).with(user)

    patch training_data_become_trainer_path
    assert_redirected_to training_data_root_path
  end

  test "become_trainer: redirects to login page when user is not logged in" do
    patch training_data_become_trainer_path
    assert_redirected_to new_user_session_path
  end
end
