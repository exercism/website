require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  test "symbolized type" do
    badge = create :badge, type: "foobar"
    assert_equal :foobar, badge.type
  end
end
