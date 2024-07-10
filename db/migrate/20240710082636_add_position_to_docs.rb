class AddPositionToDocs < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :documents, :position, :integer, null: true, limit: 1
    add_index :documents, [:track_id, :position]
    add_index :documents, [:section, :position]

    # The positions will be fixed manually by running Git::SyncMainDocss
    Document.update_all(position: 0)

    change_column_null :documents, :position, false
  end
end
