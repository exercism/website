require "test_helper"

class Mentoring::AutomationControllerTest < ActionDispatch::IntegrationTest
  test "index: renders correctly for supermentor" do
    user = create :user, :supermentor
    sign_in!(user)

    get mentoring_automation_index_path

    assert_template "mentoring/automation/index"
  end

  test "index: redirects non supermentors" do
    user = create :user
    sign_in!(user)

    get mentoring_automation_index_path
    assert_redirected_to mentoring_path
  end

  test "with_feedback: renders correctly for supermentor" do
    user = create :user, :supermentor
    sign_in!(user)

    get with_feedback_mentoring_automation_index_path

    assert_template "mentoring/automation/with_feedback"
  end

  test "with_feedback: redirects non supermentors" do
    user = create :user
    sign_in!(user)

    get with_feedback_mentoring_automation_index_path
    assert_redirected_to mentoring_path
  end
end
