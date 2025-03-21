class CoursesMailerPreview < ActionMailer::Preview
  def front_end_fundamentals_enrolled
    CoursesMailer.with(
      enrollment: CourseEnrollment.new(course_slug: "front-end-fundamentals", user_id: 1530)
    ).front_end_fundamentals_enrolled
  end

  def coding_fundamentals_enrolled
    CoursesMailer.with(
      enrollment: CourseEnrollment.new(course_slug: "coding_fundamentals", user_id: 1530)
    ).coding_fundamentals_enrolled
  end

  def bundle_coding_front_end_enrolled
    CoursesMailer.with(
      enrollment: CourseEnrollment.new(course_slug: "coding_fundamentals", user_id: 1530)
    ).bundle_coding_front_end_enrolled
  end
end
