class User::BecomeBootcampAttendee
  include Mandate

  initialize_with :user

  def call
    user.update!(bootcamp_attendee: true)
    User::SetDiscordRoles.defer(user)
    User::SetDiscourseGroups.defer(user)
  end
end
