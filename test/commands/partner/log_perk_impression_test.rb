require 'test_helper'

class Partner::LogPerkImpressionTest < ActiveSupport::TestCase
  test "iterate impression count" do
    perk = create :perk
    assert_equal 0, perk.num_impressions

    Partner::LogPerkImpression.("123", perk, nil, nil, Time.current, '')

    assert_equal 1, perk.reload.num_impressions
  end

  test "doesn't log for admin pages" do
    perk = create :perk
    assert_equal 0, perk.num_impressions

    Partner::LogPerkImpression.("123", perk, nil, nil, Time.current, '/admin/qwe')

    assert_equal 0, perk.reload.num_impressions
  end

  test "doesn't log for admin users" do
    perk = create :perk
    user = create :user, :admin
    assert_equal 0, perk.num_impressions

    Partner::LogPerkImpression.("123", perk, user, nil, Time.current, '')

    assert_equal 0, perk.reload.num_impressions
  end

  test "logs impression" do
    perk = create :perk
    user = create :user
    uuid = SecureRandom.hex
    ip_address = "127.0.0.2"
    shown_at = Time.current
    track_slug = "fooooobr"
    request_path = "/tracks/#{track_slug}/exercises"

    assert_equal 0, Exercism.mongodb_client[:perk_impressions].count

    Partner::LogPerkImpression.(uuid, perk, user, ip_address, shown_at, request_path)

    assert_equal 1, Exercism.mongodb_client[:perk_impressions].count
    record = Exercism.mongodb_client[:perk_impressions].find.to_a.first
    assert_equal uuid, record['_id']
    assert_equal perk.id, record['perk_id']
    assert_equal user.id, record['user_id']
    assert_equal ip_address, record['ip_address']
    assert_equal track_slug, record['track_slug']
    assert_equal request_path, record['shown_on']
    assert_equal "#{shown_at.year}#{shown_at.month.to_s.rjust(2, '0')}", record['shown_at_yearmonth']
    assert_equal shown_at.to_i, record['shown_at_timestamp']
  end

  test "logs impression without user" do
    perk = create :perk
    assert_equal 0, Exercism.mongodb_client[:perk_impressions].count

    Partner::LogPerkImpression.("123", perk, nil, "127.0.0.2", Time.current, 'tracks/ruby')

    assert_equal 1, Exercism.mongodb_client[:perk_impressions].count
    record = Exercism.mongodb_client[:perk_impressions].find.to_a.first
    assert_nil record['user_id']
  end

  test "logs impression with non-track URL" do
    perk = create :perk
    assert_equal 0, Exercism.mongodb_client[:perk_impressions].count

    Partner::LogPerkImpression.("123", perk, nil, "127.0.0.2", Time.current, 'foobar')

    assert_equal 1, Exercism.mongodb_client[:perk_impressions].count
    record = Exercism.mongodb_client[:perk_impressions].find.to_a.first
    assert_nil record['track_id']
  end
end
