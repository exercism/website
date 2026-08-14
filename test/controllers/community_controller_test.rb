require "test_helper"

class CommunityControllerTest < ActionDispatch::IntegrationTest
  test "renders for signed-out users" do
    Forum::RetrieveThreads.stubs(:call).returns([])

    get community_path

    assert_response :ok
  end

  test "renders for signed-in users" do
    Forum::RetrieveThreads.stubs(:call).returns([])
    sign_in!(create(:user))

    get community_path

    assert_response :ok
  end
end
