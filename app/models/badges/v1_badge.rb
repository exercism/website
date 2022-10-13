module Badges
  class V1Badge < Badge
    seed "v1",
      :common,
      'v1',
      'Joined Exercism before July 13th 2018'

    def award_to?(user)
      return false if user.confirmed_at.nil?

      user.created_at < V2_RELEASE_DATE
    end

    def send_email_on_acquisition? = false

    V2_RELEASE_DATE = Time.new(2018, 7, 13, 10, 1, 29, 0).freeze
    private_constant :V2_RELEASE_DATE
  end
end
