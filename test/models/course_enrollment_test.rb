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

  test "paid! without user or matching email" do
    Courses::CodingFundamentals.instance.expects(:enable_for_user!).never

    course_enrollment = create(:course_enrollment, :coding_fundamentals)
    course_enrollment.paid!
  end

  test "paid! with user" do
    user = create(:user)
    Courses::CodingFundamentals.instance.expects(:enable_for_user!).with(user)

    course_enrollment = create(:course_enrollment, :coding_fundamentals, user:)
    course_enrollment.paid!
  end

  test "paid! with matching email" do
    email = "foo@bar.com"
    user = create(:user, email:)
    Courses::CodingFundamentals.instance.expects(:enable_for_user!).with(user)

    course_enrollment = create(:course_enrollment, :coding_fundamentals, email:)
    course_enrollment.paid!

    assert_equal user, course_enrollment.user
  end
end
