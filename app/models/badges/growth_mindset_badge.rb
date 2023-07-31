module Badges
  class GrowthMindsetBadge < Badge
    seed "Growth mindset",
      :common,
      'mentoring',
      'Iterated a solution while working with a mentor'

    def award_to?(user)
      user.solution_mentor_discussions.joins(:solution).
        where('solutions.last_iterated_at > mentor_discussions.created_at').
        exists?
    end

    def send_email_on_acquisition? = true
  end
end
