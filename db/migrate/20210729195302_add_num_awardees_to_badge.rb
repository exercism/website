class AddNumAwardeesToBadge < ActiveRecord::Migration[6.1]
  def change
    add_column :badges, :num_awardees, :integer, default: 0, null: false
  end
end
