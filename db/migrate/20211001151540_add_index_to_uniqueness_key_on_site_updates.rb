class AddIndexToUniquenessKeyOnSiteUpdates < ActiveRecord::Migration[6.1]
  def change
    add_index :site_updates, :uniqueness_key, unique: true
  end
end
