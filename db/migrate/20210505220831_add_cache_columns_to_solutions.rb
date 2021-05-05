class AddCacheColumnsToSolutions < ActiveRecord::Migration[6.1]
  def change
    add_column :solutions, :num_views, :integer, limit: 3, null: false, default: 0
    add_column :solutions, :num_loc, :integer, limit: 3, null: false, default: 0
    add_column :solutions, :num_stars, :integer, limit: 3, null: false, default: 0
    add_column :solutions, :num_comments, :integer, limit: 3, null: false, default: 0
  end
end
