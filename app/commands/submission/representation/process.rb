class Submission::Representation::Process
  include Mandate

  initialize_with :tooling_job

  def call
    if reason == :update
      handle_update!
    else
      handle_create!
    end
  end

  def handle_create!
    create_submission_representation!

    begin
      # If we had an error then handle the error and leave
      return handle_ops_error! if submission_representation.ops_errored?

      # Otherwise, lets retrieve or create the version of this.
      create_exercise_representation!

      # If any bit of this fails, we should roll back the
      # whole thing and mark as exceptioned
      ActiveRecord::Base.transaction do
        handle_generated!
      end
    rescue StandardError
      raise unless Rails.env.production?

      # Reload the record here to ensure # that it hasn't got
      # in a bad state in the transaction above.
      submission.reload.representation_exceptioned!
    end

    submission.broadcast!
    submission.iteration&.broadcast!
  end

  def handle_update!
    create_exercise_representation!
  end

  def create_submission_representation!
    @submission_representation = Submission::Representation::Create.(
      submission, tooling_job, ast_digest
    )
  end

  def create_exercise_representation!
    @exercise_representation = Exercise::Representation::CreateOrUpdate.(
      submission,
      ast, ast_digest, mapping,
      representer_version, exercise_version,
      submission.created_at,
      git_sha
    )
  end

  def handle_ops_error!
    submission.representation_exceptioned!
  end

  def handle_generated!
    submission.representation_generated!
    create_notification!
  end

  def create_notification!
    return unless exercise_representation.has_feedback?

    # TODO: (Required) Create notification about the fact there
    # is a piece of automated feedback
  end

  private
  attr_reader :exercise_representation, :submission_representation

  memoize
  def ops_status
    tooling_job.execution_status.to_i
  end

  memoize
  def ops_success?
    ops_status == 200
  end

  def representer_version = metadata[:version] || 1
  def exercise_version = submission.solution.git_exercise.representer_version

  memoize
  def ast_digest
    Submission::Representation.digest_ast(ast)
  end

  memoize
  def submission
    Submission.find_by!(uuid: tooling_job.submission_uuid)
  end

  memoize
  def ast
    tooling_job.execution_output['representation.txt']
  rescue StandardError
    nil
  end

  memoize
  def mapping
    res = JSON.parse(tooling_job.execution_output['mapping.json'])
    res.is_a?(Hash) ? res.symbolize_keys : {}
  rescue StandardError
    {}
  end

  memoize
  def metadata
    res = JSON.parse(tooling_job.execution_output['representation.json'])
    res.is_a?(Hash) ? res.symbolize_keys : {}
  rescue StandardError
    {}
  end

  memoize
  def reason
    return nil unless tooling_job.context

    tooling_job.context.with_indifferent_access[:reason]&.to_sym
  end

  memoize
  def git_sha
    tooling_job.source["exercise_git_sha"]
  end
end
