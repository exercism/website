class AddLocationCoordinatesToMetrics < ActiveRecord::Migration[7.0]
  def change
    add_column :metrics, :coordinates, :string, null: true, if_not_exists: true
  end
end
