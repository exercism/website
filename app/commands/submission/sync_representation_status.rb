# This syncs submission's test status to the results of its latest test_run
class Submission::SyncRepresentationStatus
  include Mandate

  initialize_with :submission

  def call
    return false unless submission_representation

    if submission_representation.ops_errored?
      status = :exceptioned
    else
      status = :generated
    end

    # This will often be a noop
    submission.update!(representation_status: status)
    true
  end

  delegate :submission_representation, to: :submission
end
