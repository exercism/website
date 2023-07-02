require 'test_helper'

class Partner::LogPerkClickTest < ActiveSupport::TestCase
  test "iterate click count" do
    perk = create :perk
    assert_equal 0, perk.num_clicks

    Partner::LogPerkClick.(perk, nil, nil, nil)

    assert_equal 1, perk.reload.num_clicks
  end

  test "doesn't log for admin users" do
    perk = create :perk
    user = create :user, :admin
    assert_equal 0, perk.num_clicks

    Partner::LogPerkClick.(perk, user, nil, nil)

    assert_equal 0, perk.reload.num_clicks
  end

  test "logs click" do
    perk = create :perk
    user = create :user
    clicked_at = Time.current
    impression_uuid = SecureRandom.hex

    assert_equal 0, Exercism.mongodb_client[:perk_clicks].count

    Partner::LogPerkClick.(perk, user, clicked_at, impression_uuid)

    assert_equal 1, Exercism.mongodb_client[:perk_clicks].count
    record = Exercism.mongodb_client[:perk_clicks].find.to_a.first
    assert_equal perk.id, record['perk_id']
    assert_equal clicked_at, record['clicked_at']
    assert_equal impression_uuid, record['impression_uuid']
  end

  test "logs click without user" do
    perk = create :perk
    assert_equal 0, Exercism.mongodb_client[:perk_clicks].count

    Partner::LogPerkClick.(perk, nil, nil, nil)

    assert_equal 1, Exercism.mongodb_client[:perk_clicks].count
    record = Exercism.mongodb_client[:perk_clicks].find.to_a.first
    assert_nil record['user_id']
  end
end
