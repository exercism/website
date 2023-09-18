class AddDonatedAtToUsers < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :users, :first_donated_at, :datetime, null: true      
      remove_index :users, name: "users-supporters-page", if_not_exists: true
      add_index :users, [:first_donated_at, :show_on_supporters_page], name: "users-supporters-page", order: { first_donated_at: :desc, show_on_supporters_page: :asc }, if_not_exists: true

      User::AcquiredBadge.joins(:user).where(badge: Badges::SupporterBadge.first).each do |badge|
        badge.user.update(first_donated_at: badge.created_at)
      end
    end
  end
end
