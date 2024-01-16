class TrainingData::CodeTagsSample::Create
  include Mandate

  initialize_with :solution, dataset: :training

  def call
    return if submission.nil?
    return if submission.files.blank?

    sample = TrainingData::CodeTagsSample.find_create_or_find_by!(solution:) do |attributes|
      attributes.dataset = dataset
      attributes.status = :untagged
      attributes.files = submission.files.map do |file|
        { "filename" => file.filename, "code" => file.content }
      end
    end

    TrainingData::CodeTagsSample::GenerateTags.defer(sample) if generate_tags?(sample)

    sample
  end

  private
  memoize
  def submission = solution.latest_published_iteration_submission

  def generate_tags?(sample)
    sample.status == :untagged &&
      sample.dataset == :training &&
      sample.llm_tags.blank?
  end
end
