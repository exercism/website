require 'test_helper'

class Localization::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects to new translator path when user has no translator locales" do
    sign_in!

    get localization_root_path

    assert_redirected_to new_localization_translator_path
  end

  test "shows dashboard when user has translator locales" do
    sign_in!
    @current_user.data.update!(translator_locales: ["pt"])

    get localization_root_path

    assert_response :success
  end
end
