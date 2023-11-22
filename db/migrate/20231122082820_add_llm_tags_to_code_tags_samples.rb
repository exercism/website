class AddLlmTagsToCodeTagsSamples < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :training_data_code_tags_samples, :llm_tags, :text, null: true

    TrainingData::CodeTagsSample.update_all('llm_tags = tags')
  end
end
