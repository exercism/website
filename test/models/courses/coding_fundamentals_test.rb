require "test_helper"

class Courses::CodingFundamentalsTest < ActiveSupport::TestCase
  test "enable_for_user!" do
    user = create :user

    User::SetDiscordRoles.expects(:defer).with(user)
    User::SetDiscourseGroups.expects(:defer).with(user)

    # TODO: Assert email

    Courses::CodingFundamentals.instance.enable_for_user!(user)

    assert user.bootcamp_attendee?
  end
end
