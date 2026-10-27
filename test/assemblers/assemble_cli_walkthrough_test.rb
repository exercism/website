require "test_helper"

class AssembleCLIWalkthroughTest < ActiveSupport::TestCase
  test "renders temporary token when there is no user" do
    Git::WebsiteCopy.any_instance.stubs(:walkthrough).returns("[CONFIGURE_COMMAND]")

    expected = {
      html: "exercism configure --token=[TOKEN]"
    }
    assert_equal expected, AssembleCLIWalkthrough.(nil)
  end

  test "renders the user's active token" do
    Git::WebsiteCopy.any_instance.stubs(:walkthrough).returns("[CONFIGURE_COMMAND]")
    user = create :user
    create(:user_auth_token, user:, active: false)
    active_token = create(:user_auth_token, user:)

    expected = {
      html: "exercism configure --token=#{active_token.token}"
    }
    assert_equal expected, AssembleCLIWalkthrough.(user)
  end
end
