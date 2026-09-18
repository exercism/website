require "test_helper"

class CourseEnrollmentTest < ActiveSupport::TestCase
  test "course" do
    course_enrollment = create(:course_enrollment, :coding_fundamentals)
    assert_equal Courses::CodingFundamentals.instance, course_enrollment.course

    course_enrollment = create(:course_enrollment, :front_end_fundamentals)
    assert_equal Courses::FrontEndFundamentals.instance, course_enrollment.course

    course_enrollment = create(:course_enrollment, :bundle_coding_front_end)
    assert_equal Courses::BundleCodingFrontEnd.instance, course_enrollment.course
  end

  test "link_to_user! enables course when paid" do
    user = create(:user)
    Courses::CodingFundamentals.instance.expects(:enable_for_user!).with(user)

    course_enrollment = create(:course_enrollment, :coding_fundamentals, :paid)
    course_enrollment.link_to_user!(user)

    assert_equal user, course_enrollment.user
  end

  test "link_to_user! does not enable course when unpaid" do
    user = create(:user)
    Courses::CodingFundamentals.instance.expects(:enable_for_user!).never

    course_enrollment = create(:course_enrollment, :coding_fundamentals)
    course_enrollment.link_to_user!(user)

    assert_equal user, course_enrollment.user
  end
end
