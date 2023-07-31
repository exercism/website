class AddIndexToUniquenessKeyOnSiteUpdates < ActiveRecord::Migration[7.0]
  def change
    add_index :site_updates, :uniqueness_key, unique: true
  end
end
