class TrainingData::CodeTagsSample::FineTuneModel
  include Mandate

  def call
    file = create_file!
    file_id = upload_file!(file)
    fine_tune_model!(file_id)
  end

  private
  def create_file!
    TrainingData::CodeTagsSample::CreateFileForModelFineTuning.()
  end

  def upload_file!(file)
    response = client.files.upload(parameters: { file:, purpose: "fine-tune" })
    response["id"]
  end

  def fine_tune_model!(file_id)
    response = client.finetunes.create(
      parameters: {
        training_file: file_id,
        model: FINE_TUNE_MODEL,
        hyperparameters: {
          n_epochs: 4
        }
      }
    )
    response["id"]
  end

  memoize
  def client = Exercism.openai_client

  FINE_TUNE_MODEL = 'gpt-3.5-turbo-1106'.freeze
  private_constant :FINE_TUNE_MODEL
end
