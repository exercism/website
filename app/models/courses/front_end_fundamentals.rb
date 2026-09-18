class Courses::FrontEndFundamentals < Courses::Course
  include Singleton

  def slug = "front-end-fundamentals"

  def enable_for_user!(user)
    user.update!(bootcamp_attendee: true)
    User::SetDiscordRoles.defer(user)
    User::SetDiscourseGroups.defer(user)

    user.create_bootcamp_data! unless user.bootcamp_data
    user.bootcamp_data.update!(
      enrolled_on_part_2: true,
      part_2_level_idx: 11,
      active_part: 2
    )
  end
end
