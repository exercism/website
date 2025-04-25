require "test_helper"

class Courses::BundleCodingFrontEndTest < ActiveSupport::TestCase
  test "enable_for_user!" do
    user = create :user, :with_bootcamp_data
    Courses::Course.course_for_slug("coding-fundamentals").expects(:enable_for_user!).with(user)
    Courses::Course.course_for_slug("front-end-fundamentals").expects(:enable_for_user!).with(user)

    # TODO: Assert email

    Courses::BundleCodingFrontEnd.instance.enable_for_user!(user)
  end
end
