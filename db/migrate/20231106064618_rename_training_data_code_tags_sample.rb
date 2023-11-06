class RenameTrainingDataCodeTagsSample < ActiveRecord::Migration[7.0]
  def change
    rename_table :training_track_tags_tuples, :training_data_code_tags_samples
  end
end
