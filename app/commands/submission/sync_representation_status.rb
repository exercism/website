# This syncs submission's representation status to the results of its latest test_run
class Submission::SyncRepresentationStatus
  include Mandate

  initialize_with :submission

  def call
    return false unless representation

    if representation.ops_errored?
      status = :exceptioned
    else
      status = :generated
    end

    # This will often be a noop
    submission.update!(representation_status: status)
    true
  end

  # Get this afresh from the database - don't use reload etc
  memoize
  def representation = Submission::Representation.for!(submission)
end
