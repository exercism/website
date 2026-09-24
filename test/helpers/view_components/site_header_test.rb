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

  test "submenu links are locale-prefixed" do
    catalog = { components: { nav_submenus: { learn: { tracks: { title: "Nyelvi kurzusok" } } } } }

    with_published_translations(hu: { backend: catalog }) do
      assert_includes render(ViewComponents::SiteHeader.new), %(href="/tracks")

      I18n.with_locale(:hu) do
        html = render(ViewComponents::SiteHeader.new)
        assert_includes html, "Nyelvi kurzusok"
        assert_includes html, %(href="/hu/tracks")
        refute_includes html, %(href="/tracks")
        assert_includes html, %(href="/r/discord")
      end

      assert_includes render(ViewComponents::SiteHeader.new), %(href="/tracks")
    end
  end
end
