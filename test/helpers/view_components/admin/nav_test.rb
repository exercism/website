require "test_helper"

class ViewComponents::Admin::NavTest < ActionView::TestCase
  test "maintainers see only the maintainer group" do
    sign_in!(create(:user, :maintainer))

    html = render(ViewComponents::Admin::Nav.new("admin/site_updates"))

    assert_includes html, "Site updates"
    refute_includes html, "Community videos"
    refute_includes html, "Partners"
  end

  test "maintainer admins see the maintainer admin and maintainer groups" do
    sign_in!(create(:user, :maintainer_admin))

    html = render(ViewComponents::Admin::Nav.new("admin/site_updates"))

    assert_includes html, "Site updates"
    assert_includes html, "Community videos"
    refute_includes html, "Partners"
  end

  test "admins see every group" do
    sign_in!(create(:user, :admin))

    html = render(ViewComponents::Admin::Nav.new("admin/site_updates"))

    assert_includes html, "Site updates"
    assert_includes html, "Community videos"
    assert_includes html, "Partners"
  end

  test "marks the current page" do
    sign_in!(create(:user, :admin))

    html = render(ViewComponents::Admin::Nav.new("admin/adverts"))

    assert_match %r{<a class="selected" aria-current="page"[^>]*href="/admin/partners"}, html
  end

  test "renders nothing for users below maintainer" do
    sign_in!(create(:user, :staff))

    assert_nil render(ViewComponents::Admin::Nav.new("admin/dashboard")).presence
  end
end
