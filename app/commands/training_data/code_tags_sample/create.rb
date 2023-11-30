class TrainingData::CodeTagsSample::Create
  include Mandate

  initialize_with :solution, dataset: :training

  def call
    return if submission.nil?
    return if submission.files.blank?

    TrainingData::CodeTagsSample.find_create_or_find_by!(solution:) do |sample|
      sample.dataset = dataset
      sample.status = :untagged
      sample.files = submission.files.map do |file|
        { "filename" => file.filename, "code" => file.file_contents }
      end
    end

    # TODO: schedule fetching tags via LLM in background
  end

  private
  memoize
  def submission = solution.latest_published_iteration_submission
end
