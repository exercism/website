class CreateBadges < ActiveRecord::Migration[7.0]
  def change
    create_table :badges, if_not_exists: true do |t|
      t.string :type, null: false, index: {unique: true}
      t.string :name, null: false, index: {unique: true}
      t.string :rarity, null: false
      t.string :icon, null: false
      t.string :description, null: false

      t.integer :num_awardees, default: 0, null: false

      t.timestamps
    end
  end
end

