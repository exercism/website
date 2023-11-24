class AddCountryNameToMetrics < ActiveRecord::Migration[7.0]
  def change
    add_column :metrics, :country_name, :string, null: true
  end
end
