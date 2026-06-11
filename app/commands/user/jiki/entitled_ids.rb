module User::Jiki
  class EntitledIds
    INSIDER_STATUSES = %i[active active_lifetime].freeze

    def self.insiders
      User.joins(:data).where(user_data: { insiders_status: INSIDER_STATUSES }).pluck(:id)
    end

    def self.bootcamp_members
      from_data = User.joins(:data).
        where('user_data.bootcamp_attendee = TRUE OR user_data.bootcamp_mentor = TRUE').
        pluck(:id)

      from_bootcamp_data = User.joins(:bootcamp_data).
        where('user_bootcamp_data.enrolled_on_part_1 = TRUE OR user_bootcamp_data.enrolled_on_part_2 = TRUE').
        pluck(:id)

      (from_data + from_bootcamp_data).uniq
    end
  end
end
