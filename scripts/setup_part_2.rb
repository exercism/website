CourseEnrollment.paid.each do |ce|
  next unless ce.user

  ce.course.enable_for_user!(ce.user)

User::BootcampData.where(enrolled_on_part_1: false, enrolled_on_part_2: true).each do |ubd|
  if ubd.part_1_level_idx >= 10
    ce.user.bootcamp_data.update!(active_part: 2)
  else
    ubd.update!(active_part: 1)
  end
end