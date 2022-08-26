class Exercise::Representation::FindExamples
  include Mandate

  initialize_with :representation

  def call
    representation.
      submission_representation_submissions.
      order(created_at: :desc).
      take(NUM_EXAMPLES)
  end

  private
  def solution_files_hash(submission)
    Digest::SHA1.hexdigest(submission.files.map { |_, contents| contents }.join)
  end

  NUM_EXAMPLES = 3
  private_constant :NUM_EXAMPLES
end
