class Exercise::Representation::FindExampleSubmissions
  include Mandate

  initialize_with :representation

  def call
    example_submissions = [representation.source_submission]
    example_submission_hashes = Set.new([solution_files_hash(representation.source_submission)])
    page = 1

    loop do
      submissions = representation.
        submission_representation_submissions.
        where.not(id: representation.source_submission.id).
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
      break example_submissions if page == MAX_PAGES_FETCHED

      page += 1
    end
  end

  private
  def solution_files_hash(submission)
    Digest::SHA1.hexdigest(submission.files.map(&:content).join)
  end

  NUM_EXAMPLES = 3
  MAX_PAGES_FETCHED = 3
  private_constant :NUM_EXAMPLES, :MAX_PAGES_FETCHED
end
