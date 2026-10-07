require "test_helper"

class ViewComponents::Partner::AdvertTest < ActionView::TestCase
  test "the advert link is marked as sponsored and nofollow" do
    advert = create :advert

    html = render(ViewComponents::Partner::Advert.new(advert:, preview: true))
    link = Nokogiri::HTML(html).at_css("a.c-perk-a")

    assert_equal "sponsored nofollow noopener", link["rel"]
    assert link["href"].start_with?("/adverts/#{advert.uuid}/redirect")
  end
end
