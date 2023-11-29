class TrainingData::CodeTagsSample::NormalizeTags
  include Mandate

  initialize_with :tags

  def call
    return nil if tags.nil?

    tags.uniq
  end
end
