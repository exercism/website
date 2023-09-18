require "test_helper"

class ViewComponents::HeaderTest < ActionView::TestCase
  test "show support message when not logged in" do
    skip
    site_header_component = ViewComponents::SiteHeader.new
    site_header_component.stubs(namespace_name: "mentoring")

    html = render(site_header_component)

    assert_includes html, "Please support us if you can!"
  end

  test "show support message when logged in but not a donor" do
    skip
    site_header_component = ViewComponents::SiteHeader.new
    site_header_component.stubs(namespace_name: "mentoring")
    user = create :user
    sign_in! user

    html = render(site_header_component)

    assert_includes html, "Please support us if you can!"
  end

  test "don't show support message when logged in and a donor" do
    skip
    site_header_component = ViewComponents::SiteHeader.new
    site_header_component.stubs(namespace_name: "mentoring")
    user = create :user, :donor
    sign_in! user

    html = render(site_header_component)

    refute_includes html, "Please support us if you can!"
  end
end
