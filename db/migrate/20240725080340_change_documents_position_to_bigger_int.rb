class ChangeDocumentsPositionToBiggerInt < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    change_column :documents, :position, :integer, null: false, limit: 2, default: 0
  end
end
