class AddOptimisticLockingToUserData < ActiveRecord::Migration[7.0]
  def change
    add_column :user_data, :lock_version, :integer, default: 1
  end
end
