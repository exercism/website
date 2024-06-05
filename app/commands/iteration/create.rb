class Iteration::Create
  include Mandate

  initialize_with :solution, :submission

  def call
    time = Time.now.utc.to_formatted_s(:db)
    id = Iteration.connection.insert(%{
      INSERT INTO iterations (uuid, solution_id, submission_id, idx, created_at, updated_at)
      SELECT "#{SecureRandom.compact_uuid}", #{solution.id}, #{submission.id}, (COUNT(*) + 1), "#{time}", "#{time}"
      FROM iterations where solution_id = #{solution.id}
    })

    Iteration.find(id).tap do |iteration|
      iteration.handle_after_save!
      init_services

      solution.update_status!
      solution.update_iteration_status!
      Solution.reset_counters(solution.id, :iterations)

      snippet_job = Iteration::GenerateSnippet.defer(iteration)
      loc_job = Iteration::CountLinesOfCode.defer(iteration)

      # When the other things have finished, call publish iteration to
      # set this as the most recent iteration to the search indexes etc.
      if solution.latest_published_iteration == iteration
        Solution::PublishIteration.defer(solution, solution.published_iteration_id, prereq_jobs: [snippet_job, loc_job])
      end

      ProcessIterationForDiscussionsJob.perform_later(iteration)
      record_activity!(iteration)
      award_badges!(iteration)
      award_trophies!(iteration)
      log_metric!(iteration)
    end
  rescue ActiveRecord::RecordNotUnique
    Iteration.find_by!(solution:, submission:)
  end

  def init_services
    Submission::TestRun::Init.(submission) if submission.tests_not_queued? && solution.exercise.has_test_runner?
    Submission::Representation::Init.(submission) if submission.representation_not_queued?
    Submission::Analysis::Init.(submission) if solution.track.has_analyzer?
  end

  def record_activity!(iteration)
    User::Activity::Create.(
      :submitted_iteration,
      user,
      track: solution.track,
      solution:,
      iteration:
    )
    # rescue StandardError => e
    #   Rails.logger.error "Failed to create activity"
    #   Rails.logger.error e.message
  end

  def award_badges!(iteration)
    AwardBadgeJob.perform_later(user, :die_unendliche_geschichte, context: iteration)
    AwardBadgeJob.perform_later(user, :growth_mindset)
    AwardBadgeJob.perform_later(user, :new_years_resolution, context: iteration)
    AwardBadgeJob.perform_later(user, :participant_in_12_in_23)
  end

  def award_trophies!(iteration)
    AwardTrophyJob.perform_later(user, track, :iterated_twenty_exercises, context: iteration)
  end

  def log_metric!(iteration)
    Metric::Queue.(:submit_iteration, iteration.created_at, iteration:, track:, user:)
  end

  delegate :track, :user, to: :solution
end
