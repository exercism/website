class CreateUserAcquiredBadges < ActiveRecord::Migration[6.1]
  def up
    begin
      remove_belongs_to :users, :featured_badge
    rescue ActiveRecord::StatementInvalid
    end

    drop_table :badges

    create_table :badges do |t|
      t.string :type, null: false
      t.string :name, null: false
      t.string :rarity, null: false
      t.string :icon, null: false
      t.string :description, null: false

      t.timestamps

      t.index :type, unique: true
      t.index :name, unique: true
    end
 
    create_table :user_acquired_badges do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :badge, foreign_key: true, null: false

      t.index [:user_id, :badge_id], unique: true
      t.timestamps
    end
  end

  def down
    drop_table :user_acquired_badges
  end
end
