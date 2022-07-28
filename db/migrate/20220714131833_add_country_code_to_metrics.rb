class AddCountryCodeToMetrics < ActiveRecord::Migration[7.0]
  def change
    add_column :metrics, :country_code, :string, limit: 2, null: true, if_not_exists: true
  end
end
