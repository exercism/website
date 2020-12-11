class AddPublishedToIterations < ActiveRecord::Migration[6.1]
  def change
    add_column :iterations, :published, :boolean, null: false, default: false
  end
end
