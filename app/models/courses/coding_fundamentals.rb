class Courses::CodingFundamentals < Courses::Course
  include Singleton

  def slug = "coding-fundamentals"
  def url = "https://jiki.io"
  def self.url = instance.url

  def enable_for_user!(user)
    user.update!(bootcamp_attendee: true)
    User::SetDiscordRoles.defer(user)
    User::SetDiscourseGroups.defer(user)

    user.create_bootcamp_data! unless user.bootcamp_data
    user.bootcamp_data.update!(enrolled_on_part_1: true, active_part: 1)
  end
end
