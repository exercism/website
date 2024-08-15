class AddPositionToDocs < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :documents, :position, :integer, null: false, limit: 1, default: 0
    add_index :documents, [:track_id, :position]
    add_index :documents, [:section, :position]
  end
end
