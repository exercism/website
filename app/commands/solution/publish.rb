class Solution
  class Publish
    include Mandate

    initialize_with :solution, :user_track, :iteration_idx

    def call
      Solution::Complete.(solution, user_track) unless solution.completed?

      solution.with_lock do
        return if solution.published?

        ActiveRecord::Base.transaction do
          solution.update(published_at: Time.current)
          Solution::PublishIteration.(solution, iteration_idx)
        end
      end

      award_reputation!
      record_activity!
      log_metric!
    end

    private
    def award_reputation!
      level = solution.exercise.concept_exercise? ? :concept : solution.exercise.difficulty_category
      AwardReputationTokenJob.perform_later(
        solution.user,
        :published_solution,
        solution:,
        level:
      )
    end

    def record_activity!
      User::Activity::Create.(
        :published_exercise,
        solution.user,
        track: solution.track,
        solution:
      )
    rescue StandardError => e
      Rails.logger.error "Failed to create activity"
      Rails.logger.error e.message
    end

    def log_metric!
      Metric::Queue.(:publish_solution, solution.published_at, solution:, track: user_track.track, user: user_track.user)
    end
  end
end
