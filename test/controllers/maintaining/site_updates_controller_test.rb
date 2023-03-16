require "test_helper"

class Maintaining::SiteUpdatesControllerTest < ActionDispatch::IntegrationTest
  test "index - redirects non maintainers" do
    user = create :user
    sign_in!(user)

    get maintaining_site_updates_path
    assert_redirected_to root_path
  end

  test "index - shows for maintainer" do
    user = create :user, :maintainer
    sign_in!(user)

    get maintaining_site_updates_path
    assert_response :ok
  end

  test "new - redirects non maintainers" do
    user = create :user
    sign_in!(user)

    get new_maintaining_site_update_path
    assert_redirected_to root_path
  end

  test "new - shows for maintainer" do
    user = create :user, :maintainer
    sign_in!(user)

    get new_maintaining_site_update_path
    assert_response :ok
  end

  test "edit - redirects non maintainers" do
    update = create :site_update
    user = create :user
    sign_in!(user)

    get edit_maintaining_site_update_path(update)
    assert_redirected_to root_path
  end

  test "edit - shows for maintainer" do
    update = create :site_update
    user = create :user, :maintainer
    sign_in!(user)

    get edit_maintaining_site_update_path(update)
    assert_response :ok
  end
end
