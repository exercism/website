module Badges
  class MentorBadge < Badge
    seed "Mentor",
      :rare,
      :mentor,
      "Mentored 10 students"

    def award_to?(user)
      user.mentor_discussions.joins(:request).
        where(status: :finished).
        select('mentor_requests.student_id').
        distinct.
        count >= 10
    end

    def send_email_on_acquisition? = false
  end
end
