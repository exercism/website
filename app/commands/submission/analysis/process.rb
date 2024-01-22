class Submission::Analysis::Process
  include Mandate

  initialize_with :tooling_job

  def call
    # Firstly create a record for debugging and to give
    # us some basis of the next set of decisions etc.
    analysis = submission.create_analysis!(
      tooling_job_id: tooling_job.id,
      ops_status:,
      data:,
      tags_data:
    )

    begin
      # If any bit of this fails, we should roll back the
      # whole thing and mark as exceptioned
      ActiveRecord::Base.transaction do
        if analysis.ops_errored?
          handle_ops_error!
        else
          handle_completed!
        end
      end
    rescue StandardError
      # Reload the record here to ensure # that it hasn't got
      # in a bad state in the transaction above.
      submission.reload.analysis_exceptioned!
    end

    submission.broadcast!
    submission.iteration&.broadcast!
  end

  private
  def ops_status = tooling_job.execution_status.to_i
  def ops_errored? = ops_status != 200

  def handle_ops_error!
    submission.analysis_exceptioned!
  end

  def handle_completed!
    submission.analysis_completed!
    submission.update!(tags:)
    Solution::UpdateTags.(submission.solution)
    Submission::LinkToMatchingApproach.(submission)
  end

  memoize
  def submission
    Submission.find_by!(uuid: tooling_job.submission_uuid)
  end

  memoize
  def data
    return {} if ops_errored?

    res = JSON.parse(tooling_job.execution_output['analysis.json'])
    res.is_a?(Hash) ? res.symbolize_keys : {}
  rescue StandardError => e
    Bugsnag.notify(e)
    {}
  end

  memoize
  def tags_data
    return {} if ops_errored?

    tags_json = tooling_job.execution_output['tags.json']
    return {} if tags_json.blank?

    res = JSON.parse(tags_json)
    res.is_a?(Hash) ? res.symbolize_keys : {}
  rescue StandardError => e
    Bugsnag.notify(e)
    {}
  end

  memoize
  def tags = tags_data[:tags]
end
