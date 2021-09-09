class Solution
  class Publish
    include Mandate

    initialize_with :solution, :user_track, :iteration_idx

    def call
      Solution::Complete.(solution, user_track) unless solution.completed?

      solution.with_lock do
        return if solution.published?

        ActiveRecord::Base.transaction do
          solution.update(
            published_at: Time.current,
            published_iteration_id: published_iteration_id
          )
        end
      end

      award_reputation!
      record_activity!
    end

    def award_reputation!
      level = solution.exercise.concept_exercise? ? :easy : solution.exercise.difficulty_category
      AwardReputationTokenJob.perform_later(
        solution.user,
        :published_solution,
        solution: solution,
        level: level
      )
    end

    def record_activity!
      User::Activity::Create.(
        :published_exercise,
        solution.user,
        track: solution.track,
        solution: solution
      )
    rescue StandardError => e
      Rails.logger.error "Failed to create activity"
      Rails.logger.error e.message
    end

    def published_iteration_id
      return nil unless iteration_idx

      solution.iterations.where(idx: iteration_idx).pick(:id)
    end
  end
end
