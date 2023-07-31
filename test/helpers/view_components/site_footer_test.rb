require "test_helper"

class ViewComponents::SiteFooterTest < ActionView::TestCase
  test "unauthenticed request" do
    create :track, title: 'Ruby'

    html = render(ViewComponents::SiteFooter.new)
    assert_includes html, "Sign up for free"
    assert_includes html, "Terms of usage"
    assert_includes html, "Ruby"
  end

  test "authenticed request" do
    create :track, title: 'Ruby'
    user = create :user
    sign_in! user

    html = render(ViewComponents::SiteFooter.new)
    refute_includes html, "Sign up for free"
    assert_includes html, "Terms of usage"
    assert_includes html, "Ruby"
  end

  test "new languages are shown after existing content is cached" do
    create :track, title: 'Ruby', slug: 'ruby'
    user = create :user
    sign_in! user

    html = render(ViewComponents::SiteFooter.new)
    refute_includes html, "Sign up for free"
    assert_includes html, "Terms of usage"
    assert_includes html, "Ruby"

    create :track, title: 'Nim', slug: 'nim'
    html = render(ViewComponents::SiteFooter.new)
    assert_includes html, "Nim"
    assert_includes html, "Ruby"
  end
end
