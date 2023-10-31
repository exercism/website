require 'test_helper'

class Partner::LogAdvertImpressionTest < ActiveSupport::TestCase
  test "iterate impression count" do
    advert = create :advert
    assert_equal 0, advert.num_impressions

    Partner::LogAdvertImpression.("123", advert, nil, nil, Time.current, '')

    assert_equal 1, advert.reload.num_impressions
  end

  test "doesn't log for admin pages" do
    advert = create :advert
    assert_equal 0, advert.num_impressions

    Partner::LogAdvertImpression.("123", advert, nil, nil, Time.current, '/admin/qwe')

    assert_equal 0, advert.reload.num_impressions
  end

  test "doesn't log for admin users" do
    advert = create :advert
    user = create :user, :admin
    assert_equal 0, advert.num_impressions

    Partner::LogAdvertImpression.("123", advert, user, nil, Time.current, '')

    assert_equal 0, advert.reload.num_impressions
  end
end
