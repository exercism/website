require "test_helper"

class AssembleCLIWalkthroughTest < ActiveSupport::TestCase
  test "renders temporary token when there is no user" do
    Git::WebsiteCopy.any_instance.stubs(:walkthrough).returns("[CONFIGURE_COMMAND]")

    expected = {
      html: "exercism configure --token=[TOKEN]"
    }
    assert_equal expected, AssembleCLIWalkthrough.(nil)
  end
end
