class CreateUserAcquiredBadges < ActiveRecord::Migration[6.1]
  def up
    create_table :user_acquired_badges do |t|

      t.string :uuid, null: false

      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :badge, foreign_key: true, null: false

      t.boolean :revealed, null: false, default: false 

      t.index [:user_id, :badge_id], unique: true

      t.timestamps

      t.index :uuid, unique: true
    end
  end

  def down
    drop_table :user_acquired_badges
  end
end
