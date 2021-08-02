class AddDeletedAtToIterations < ActiveRecord::Migration[6.1]
  def change
    add_column :iterations, :deleted_at, :datetime, null: true
  end
end
