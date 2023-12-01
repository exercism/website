class AddCheckedByToSamples < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :training_data_code_tags_samples, :checked_by_id, :bigint, null: true
  end
end
