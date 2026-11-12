class DropTrainingData < ActiveRecord::Migration[7.1]
  def up
    return if Rails.env.production?

    drop_table :training_data_code_tags_samples
    remove_column :user_data, :trainer
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
