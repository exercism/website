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

  test "logs impression" do
    advert = create :advert
    user = create :user
    uuid = SecureRandom.hex
    ip_address = "127.0.0.2"
    shown_at = Time.current
    track_slug = "fooooobr"
    request_path = "/tracks/#{track_slug}/exercises"

    assert_equal 0, Exercism.mongodb_client[:advert_impressions].count

    Partner::LogAdvertImpression.(uuid, advert, user, ip_address, shown_at, request_path)

    assert_equal 1, Exercism.mongodb_client[:advert_impressions].count
    record = Exercism.mongodb_client[:advert_impressions].find.to_a.first
    assert_equal uuid, record['_id']
    assert_equal advert.id, record['advert_id']
    assert_equal user.id, record['user_id']
    assert_equal ip_address, record['ip_address']
    assert_equal track_slug, record['track_slug']
    assert_equal request_path, record['shown_on']
    assert_equal "#{shown_at.year}#{shown_at.month.to_s.rjust(2, '0')}", record['shown_at_yearmonth']
    assert_equal shown_at.to_i, record['shown_at_timestamp']
  end

  test "logs impression without user" do
    advert = create :advert
    assert_equal 0, Exercism.mongodb_client[:advert_impressions].count

    Partner::LogAdvertImpression.("123", advert, nil, "127.0.0.2", Time.current, 'tracks/ruby')

    assert_equal 1, Exercism.mongodb_client[:advert_impressions].count
    record = Exercism.mongodb_client[:advert_impressions].find.to_a.first
    assert_nil record['user_id']
  end

  test "logs impression with non-track URL" do
    advert = create :advert
    assert_equal 0, Exercism.mongodb_client[:advert_impressions].count

    Partner::LogAdvertImpression.("123", advert, nil, "127.0.0.2", Time.current, 'foobar')

    assert_equal 1, Exercism.mongodb_client[:advert_impressions].count
    record = Exercism.mongodb_client[:advert_impressions].find.to_a.first
    assert_nil record['track_id']
  end
end
