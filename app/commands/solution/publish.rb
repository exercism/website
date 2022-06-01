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
          Solution::UpdateSnippet.(solution)
        end
      end

      award_reputation!
      record_activity!
    end

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
  end
end
