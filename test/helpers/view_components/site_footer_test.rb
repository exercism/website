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

  test "is cached per locale, and a published fix busts it" do
    create :track, title: 'Ruby'
    catalog = lambda { |text|
      { components: { footer: { shared: { site_links: { legal_and_policies: { terms_of_usage_link: text } } } } } }
    }

    with_published_translations(hu: { backend: catalog.("Felhasználási feltételek") }) do
      assert_includes render(ViewComponents::SiteFooter.new), "Terms of usage"

      I18n.with_locale(:hu) do
        html = render(ViewComponents::SiteFooter.new)
        assert_includes html, "Felhasználási feltételek"
        assert_includes html, %(href="/hu/)

        publish_translation_catalog!(:hu, :backend, catalog.("Javított feltételek"))
        assert_includes render(ViewComponents::SiteFooter.new), "Javított feltételek"
      end

      assert_includes render(ViewComponents::SiteFooter.new), "Terms of usage"
    end
  end
end
