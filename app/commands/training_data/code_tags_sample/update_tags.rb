class TrainingData::CodeTagsSample::UpdateTags
  include Mandate

  initialize_with :sample, :tags, :status, :user

  def call
    sample.with_lock do
      sample.lock_for_editing!(user)
      sample.update!(tags:, status:)
      sample.unlock!
    end
  end
end
