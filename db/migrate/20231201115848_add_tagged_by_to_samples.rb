class AddTaggedByToSamples < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :training_data_code_tags_samples, :tagged_by_id, :bigint, null: true
  end
end
