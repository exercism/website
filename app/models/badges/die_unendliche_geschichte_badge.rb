module Badges
  class DieUnendlicheGeschichteBadge < Badge
    seed "Die Unendliche Geschichte",
      :rare,
      'die-unendliche-geschichte',
      'Submitted 10 iterations to the same exercise'

    def self.worth_queuing?(iteration:)
      iteration.idx >= 10
    end

    def award_to?(user)
      user.iterations.
        group(:solution_id).
        having('COUNT(solution_id) >= 10').
        exists?
    end

    def send_email_on_acquisition? = true
  end
end
