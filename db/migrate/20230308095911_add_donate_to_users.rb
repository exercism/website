class AddDonateToUsers < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :users, :donated, :boolean, null: false, default: false

      User.where('total_donated_in_cents > 0').update_all(donated: true)
    end
  end
end
