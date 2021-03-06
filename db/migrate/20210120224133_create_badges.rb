class CreateBadges < ActiveRecord::Migration[6.1]
  def up
    create_table :badges do |t|
      t.string :type, null: false, index: {unique: true}
      t.string :name, null: false, index: {unique: true}
      t.string :rarity, null: false
      t.string :icon, null: false
      t.string :description, null: false

      t.timestamps
    end
  end

  def down
    drop_table :badges
  end
end

