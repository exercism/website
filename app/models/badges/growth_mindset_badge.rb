module Badges
  class GrowthMindsetBadge < Badge
    seed "Growth Mindset",
      :common,
      'mentoring',
      'Awarded for iterating a solution while working with a mentor'

    def award_to?(user)
      user.solution_mentor_discussions.joins(:solution).
        where('solutions.last_iterated_at > mentor_discussions.created_at').
        exists?
    end
  end
end
