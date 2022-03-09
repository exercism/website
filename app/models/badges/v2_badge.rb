module Badges
  class V2Badge < Badge
    seed "V2",
      :common,
      'v2',
      'Awarded for having joined Exercism v2'

    def award_to?(user)
      return false if user.confirmed_at.nil?

      user.created_at < V3_RELEASE_DATE
    end

    def send_email_on_acquisition?
      false
    end

    V3_RELEASE_DATE = Time.new(2021, 9, 1, 0, 0, 0, 0).freeze
    private_constant :V3_RELEASE_DATE
  end
end
