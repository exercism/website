class AddRevealedToAcquiredBadges < ActiveRecord::Migration[6.1]
  def change
    add_column :user_acquired_badges, :revealed, :boolean, null: false, default: false 
  end
end
