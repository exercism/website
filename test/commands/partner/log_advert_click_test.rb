require 'test_helper'

class Partner::LogAdvertClickTest < ActiveSupport::TestCase
  test "iterate click count" do
    advert = create :advert
    assert_equal 0, advert.num_clicks

    Partner::LogAdvertClick.(advert, nil, nil, nil)

    assert_equal 1, advert.reload.num_clicks
  end

  test "doesn't log for admin users" do
    advert = create :advert
    user = create :user, :admin
    assert_equal 0, advert.num_clicks

    Partner::LogAdvertClick.(advert, user, nil, nil)

    assert_equal 0, advert.reload.num_clicks
  end
end
