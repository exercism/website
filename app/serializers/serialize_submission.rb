class SerializeSubmission
  include Mandate

  initialize_with :submission

  def call
    {
      uuid: submission.uuid,
      tests_status: submission.tests_status
    }
  end
end
