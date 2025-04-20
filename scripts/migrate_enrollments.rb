# 4184
# 8207

package_to_course = {
  "part_1": "coding-fundamentals",
  "part_2": "front-end-fundamentals",
  "complete": "bundle-coding-front-end",
}

User::BootcampData.not_paid.find_each do |bd|
  next unless bd.user_id.present?
  next unless bd.enrolled_at.present?
  next unless bd.package.present?

  course_slug = package_to_course[bd.package.to_sym]

  ce = CourseEnrollment.find_by(user_id: bd.user_id)
  next if ce

  CourseEnrollment.create!(
    user_id: bd.user_id,
    course_slug: course_slug,
    name: bd.name || bd.user.name,
    email: bd.email || bd.user.email,
    country_code_2: bd.ppp_country,
  )
end