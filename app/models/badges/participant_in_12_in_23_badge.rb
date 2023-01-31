module Badges
  class ParticipantIn12In23Badge < Badge
    seed "12 in 23",
      :rare,
      '12-in-23',
      'Participated in the #12in23 challenge and completed 5 exercises in a track'

    def award_to?(user)
      challenge = user.challenges.find_by(challenge_id: User::Challenge::CHALLENGE_12_IN_23)
      return false if challenge.nil?

      user.solutions.completed.joins(exercise: :track).
        where('completed_at >= ?', challenge.created_at).
        group(:track_id).
        having("count(*) >= 5").
        exists?
    end

    def send_email_on_acquisition? = true
  end
end
