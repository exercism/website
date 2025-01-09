class User::LinkWithBootcampData
  include Mandate

  initialize_with :user, :bootcamp_data

  def call
    return unless bootcamp_data

    reset_current_user!
    reset_old_user!
    bootcamp_data.update!(user:)
    User::Bootcamp::SubscribeToOnboardingEmails.defer(bootcamp_data)

    return unless bootcamp_data.paid?

    user.update!(bootcamp_attendee: true)
    User::SetDiscordRoles.defer(user)
    User::SetDiscourseGroups.defer(user)
  end

  memoize

  def reset_current_user!
    existing_data = User::BootcampData.find_by(user:)
    return unless existing_data

    existing_data.update!(user: nil)
  end

  def reset_old_user!
    return unless bootcamp_data.user

    bootcamp_data.user.update!(bootcamp_attendee: false)
  end
end
