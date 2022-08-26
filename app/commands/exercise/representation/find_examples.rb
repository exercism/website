class Exercise::Representation::FindExamples
  include Mandate

  initialize_with :representation

  def call
    example_submissions = []
    example_submission_hashes = Set.new
    page = 1

    loop do
      submissions = representation.
        submission_representation_submissions.
        order(created_at: :desc).
        page(page).
        per(NUM_EXAMPLES)

      submissions.each do |submission|
        return example_submissions if example_submissions.size == NUM_EXAMPLES

        hash = solution_files_hash(submission)
        next if example_submission_hashes.include?(hash)

        example_submissions << submission
        example_submission_hashes << hash
      end

      break example_submissions if submissions.last_page?

      page = submissions.next_page
    end
  end

  private
  def solution_files_hash(submission)
    Digest::SHA1.hexdigest(submission.files.map(&:content).join)
  end

  NUM_EXAMPLES = 3
  private_constant :NUM_EXAMPLES
end
