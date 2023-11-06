class AddUuidToCodeTagsSamples < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :training_data_code_tags_samples, :uuid, :string, null: true

    TrainingData::CodeTagsSample.find_each do |sample|
      sample.update!(uuid: SecureRandom.compact_uuid)
    end

    change_column_null :training_data_code_tags_samples, :uuid, false
  end
end
