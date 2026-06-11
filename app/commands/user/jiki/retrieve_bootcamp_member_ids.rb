class User::Jiki::RetrieveBootcampMemberIds
  include Mandate

  def call
    (from_data + from_bootcamp_data).uniq
  end

  private
  def from_data
    User.joins(:data).
      where('user_data.bootcamp_attendee = TRUE OR user_data.bootcamp_mentor = TRUE').
      pluck(:id)
  end

  def from_bootcamp_data
    User.joins(:bootcamp_data).
      where('user_bootcamp_data.enrolled_on_part_1 = TRUE OR user_bootcamp_data.enrolled_on_part_2 = TRUE').
      pluck(:id)
  end
end
