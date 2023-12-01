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
        { "filename" => file.filename, "code" => file.content }
      end
    end

    TrainingData::CodeTagsSample::GenerateTags.defer(sample) if sample.llm_tags.blank?
  end

  private
  memoize
  def submission = solution.latest_published_iteration_submission
end
