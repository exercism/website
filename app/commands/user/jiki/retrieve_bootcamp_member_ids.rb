class User::Jiki::RetrieveBootcampMemberIds
  include Mandate

  def call
    (from_data + from_bootcamp_data).uniq
  end

  private
  def from_data
    User::Data.where(bootcamp_attendee: true).pluck(:user_id) +
      User::Data.where(bootcamp_mentor: true).pluck(:user_id)
  end

  def from_bootcamp_data
    User.joins(:bootcamp_data).
      where('user_bootcamp_data.enrolled_on_part_1 = TRUE OR user_bootcamp_data.enrolled_on_part_2 = TRUE').
      pluck(:id)
  end
end
