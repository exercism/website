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
        order(id: :desc).
        page(page).
        per(NUM_EXAMPLES * 2)

      submissions.each do |submission|
        return example_submissions.values if example_submissions.size == NUM_EXAMPLES
        next if submission == representation.source_submission

        hash = solution_files_hash(submission)
        next if example_submissions.key?(hash)

        example_submissions[hash] = submission
      end

      return example_submissions.values if submissions.last_page?
      return example_submissions.values if page == MAX_PAGES_FETCHED

      page += 1
    end
  end

  private
  def solution_files_hash(submission)
    submission.files.map(&:digest).join
  end

  NUM_EXAMPLES = 3
  MAX_PAGES_FETCHED = 3
  private_constant :NUM_EXAMPLES, :MAX_PAGES_FETCHED
end
