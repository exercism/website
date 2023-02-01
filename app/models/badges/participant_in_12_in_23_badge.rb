module Badges
  class ParticipantIn12In23Badge < Badge
    seed "#12in23 Participant",
      :rare,
      '12in23-start',
      'Participated in the #12in23 challenge and completed 5 exercises in a track'

    def award_to?(user)
      challenge = user.challenges.find_by(challenge_id: User::Challenge::CHALLENGE_12_IN_23)
      return false if challenge.nil?

      user.solutions.joins(exercise: :track).
        where('last_iterated_at > ?', Date.new(2022, 12, 31)).
        group(:track_id).
        having("count(*) >= 5").
        exists?
    end

    def send_email_on_acquisition? = true
  end
end
