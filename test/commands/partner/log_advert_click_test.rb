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

  test "logs click" do
    advert = create :advert
    user = create :user
    clicked_at = Time.current
    impression_uuid = SecureRandom.hex

    assert_equal 0, Exercism.mongodb_client[:advert_clicks].count

    Partner::LogAdvertClick.(advert, user, clicked_at, impression_uuid)

    assert_equal 1, Exercism.mongodb_client[:advert_clicks].count
    record = Exercism.mongodb_client[:advert_clicks].find.to_a.first
    assert_equal advert.id, record['advert_id']
    assert_equal clicked_at, record['clicked_at']
    assert_equal impression_uuid, record['impression_uuid']
  end

  test "logs click without user" do
    advert = create :advert
    assert_equal 0, Exercism.mongodb_client[:advert_clicks].count

    Partner::LogAdvertClick.(advert, nil, nil, nil)

    assert_equal 1, Exercism.mongodb_client[:advert_clicks].count
    record = Exercism.mongodb_client[:advert_clicks].find.to_a.first
    assert_nil record['user_id']
  end
end
