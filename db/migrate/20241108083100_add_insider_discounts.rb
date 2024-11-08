class AddInsiderDiscounts < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    
    add_column :user_data, :bootcamp_affiliate_coupon_code, :string, null: true
    add_column :user_data, :bootcamp_free_coupon_code, :string, null: true
  end
end
