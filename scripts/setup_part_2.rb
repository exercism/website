CourseEnrollment.paid.each do |ce|
  next unless ce.user

  ce.course.enable_for_user!(ce.user)

  if ce.user.bootcamp_data.part_1_level_idx >= 11 && ce.user.bootcamp_data.enrolled_on_part_2?
    ce.user.bootcamp_data.update!(active_part: 2)
  end
end