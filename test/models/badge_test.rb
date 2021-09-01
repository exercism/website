require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  test "percentage_awardees" do
    badge = create :badge, num_awardees: 123_456
    assert_equal 15.44, badge.percentage_awardees
  end
end
