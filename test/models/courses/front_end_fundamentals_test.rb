require "test_helper"

class Courses::FrontEndFundamentalsTest < ActiveSupport::TestCase
  test "enable_for_user!" do
    user = create :user

    # TODO: Assert email

    Courses::FrontEndFundamentals.instance.enable_for_user!(user)
  end
end
