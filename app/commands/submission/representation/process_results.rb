class Submission::Representation::ProcessResults
  include Mandate

  initialize_with :submission, :git_sha,
    :reason,
    :tooling_job_id, :ops_status,
    :ast, :ast_digest, :mapping,
    :representer_version, :exercise_version

  def call
    if reason == :update
      handle_update!
    else
      handle_create!
    end
  end

  private
  attr_reader :exercise_representation, :submission_representation

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
    rescue StandardError => e
      raise unless Rails.env.production?

      # Alert bugsnag and mark as exceptioned
      Bugsnag.notify(e)

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
      submission, tooling_job_id, ops_status,
      ast_digest, exercise_version
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
    return unless exercise_representation.has_feedback? # rubocop:disable Style/RedundantReturn

    # TODO: (Required) Create notification about the fact there
    # is a piece of automated feedback
  end
end
