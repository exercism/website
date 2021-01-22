class SerializeSubmissions
  include Mandate

  initialize_with :submissions

  def call
    return [] if submissions.blank?

    submissions.includes(:solution).
      map { |s| SerializeSubmission.(s) }
  end
end
