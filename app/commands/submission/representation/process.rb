class Submission::Representation::Process
  include Mandate

  initialize_with :tooling_job

  def call
    Submission::Representation::ProcessResults.(
      submission, git_sha,
      reason,
      tooling_job.id, ops_status,
      ast, ast_digest, mapping,
      representer_version, exercise_version
    )
  end

  private
  def ops_status = tooling_job.execution_status.to_i
  def ops_errored? = ops_status != 200
  def ast_digest = Submission::Representation.digest_ast(ast)
  def representer_version = metadata[:version] || 1

  def exercise_version
    git_exercise = Git::Exercise.for_solution(solution, git_sha:)
    git_exercise.representer_version
  end

  memoize
  def submission
    Submission.find_by!(uuid: tooling_job.submission_uuid)
  end
  delegate :solution, :exercise, to: :submission

  memoize
  def ast
    return nil if ops_errored?

    tooling_job.execution_output['representation.txt']
  rescue StandardError => e
    Bugsnag.notify(e)
    nil
  end

  memoize
  def mapping
    return {} if ops_errored?

    res = JSON.parse(tooling_job.execution_output['mapping.json'])
    res.is_a?(Hash) ? res.symbolize_keys : {}
  rescue StandardError => e
    Bugsnag.notify(e)
    {}
  end

  memoize
  def metadata
    return {} if ops_errored?

    representation_json = tooling_job.execution_output['representation.json']
    return {} if representation_json.blank?

    res = JSON.parse(representation_json)
    res.is_a?(Hash) ? res.symbolize_keys : {}
  rescue StandardError => e
    Bugsnag.notify(e)
    {}
  end

  memoize
  def reason
    return nil unless tooling_job.context

    tooling_job.context.with_indifferent_access[:reason]&.to_sym
  end

  memoize
  def git_sha = tooling_job.source["exercise_git_sha"]
end
