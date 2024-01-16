require 'test_helper'

class Partner::LogPerkClickTest < ActiveSupport::TestCase
  test "iterate click count" do
    perk = create :perk
    assert_equal 0, perk.num_clicks

    Partner::LogPerkClick.(perk, nil, nil)

    assert_equal 1, perk.reload.num_clicks
  end

  test "doesn't log for admin users" do
    perk = create :perk
    user = create :user, :admin
    assert_equal 0, perk.num_clicks

    Partner::LogPerkClick.(perk, user, nil)

    assert_equal 0, perk.reload.num_clicks
  end
end
