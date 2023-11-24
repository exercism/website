class AddCountryNameToMetrics < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    
    add_column :metrics, :country_name, :string, null: true
  end
end
