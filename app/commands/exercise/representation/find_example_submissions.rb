class Exercise::Representation::FindExampleSubmissions
  include Mandate

  initialize_with :representation

  def call
    source_submission_hash = solution_files_hash(representation.source_submission)
    example_submissions = { source_submission_hash => representation.source_submission }
    page = 1

    loop do
      submissions = representation.
        submission_representation_submissions.
        order(created_at: :desc).
        page(page).
        per(NUM_EXAMPLES)

      submissions.each do |submission|
        next if submission == representation.source_submission
        return example_submissions.values if example_submissions.size == NUM_EXAMPLES

        hash = solution_files_hash(submission)
        next if example_submissions.key?(hash)

        example_submissions[hash] = submission
      end

      break example_submissions.values if submissions.last_page?
      break example_submissions.values if page == MAX_PAGES_FETCHED

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
