class CreateUserBadges < ActiveRecord::Migration[6.0]
  def change
    create_table :user_badges do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :badge, foreign_key: true, null: false

      t.timestamps

      t.index [:user_id, :badge_id], unique: true
    end

    add_belongs_to :users, :featured_user_badge, null: true, foreign_key: {to_table: "user_badges"}
  end
end
