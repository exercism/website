require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  test "only one badge can be created per user" do
    user = create :user
    create :badge, user: user

    assert_raises do
      create :badge, user: user
    end
  end
end
