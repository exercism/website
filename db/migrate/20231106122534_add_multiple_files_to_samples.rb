class AddMultipleFilesToSamples < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :training_data_code_tags_samples, :files, :text, null: false

    TrainingData::CodeTagsSample.find_each do |sample|
      solution = sample.solution
      sample.update(
        files: [{
          filename: solution.iterations.last.files.first.filename,
          code: sample.code
        }]
       )
    end

    change_column_null :training_data_code_tags_samples, :files, false
    remove_column :training_data_code_tags_samples, :code
  end
end
