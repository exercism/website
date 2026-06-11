class User::Jiki::DetermineUserStatus
  include Mandate

  initialize_with :user

  def call
    {
      is_insider: insider?,
      is_bootcamp_member: bootcamp_member?
    }
  end

  private
  def insider?
    return false unless user

    user.data.insiders_status_active? || user.data.insiders_status_active_lifetime?
  end

  def bootcamp_member?
    return false unless user
    return true if user.bootcamp_mentor?
    return false unless user.bootcamp_data

    user.bootcamp_data.enrolled_on_part_1? || user.bootcamp_data.enrolled_on_part_2?
  end
end
