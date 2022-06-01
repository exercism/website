class NudgeUsersToRequestMentoringJob < ApplicationJob
  queue_as :notifications

  def perform
    # Don't change this without actively benchmarking it on bastion.
    # Things that logically feel like they should make it faster often don't.
    # At time of writing it takes 4.8s.
    user_ids = Iteration.joins(solution: :exercise).
      # Iterated since v3 launch
      where('iterations.created_at >= ?', Date.new(2021, 9, 1)).
      # Iterated over a day ago (give time to request manually)
      where('iterations.created_at < ?', Time.current - 1.day).

      # Don't include Concept Exercises as we don't nudge on those
      where('solutions.type': 'PracticeSolution').

      # Don't include hello-world
      where.not('exercises.slug': 'hello-world').

      # Not for users who have mentor requests
      where.not('solutions.user_id': Mentor::Request.select(:student_id)).

      # Not for users who have already had the notification
      where.not('solutions.user_id': User::Notifications::NudgeToRequestMentoringNotification.select(:user_id)).

      # Just the user ids
      pluck('solutions.user_id').uniq

    user_ids.in_groups_of(100) do |batch|
      User.find(batch).each do |user|
        track = PracticeSolution.where(user:).where.not(status: :started).
          joins(:exercise).where.not('exercises.slug': 'hello-world').
          last.track

        User::Notification::Create.(
          user,
          :nudge_to_request_mentoring,
          track:
        )
      end
    end
  end
end
