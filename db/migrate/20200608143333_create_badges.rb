class CreateBadges < ActiveRecord::Migration[6.0]
  def change
    create_table :badges do |t|
      t.belongs_to :user, foreign_key: true, null: false

      t.string :type, null: false

      t.timestamps

      t.index [:user_id, :type], unique: true
    end

    add_belongs_to :users, :featured_badge, null: true, foreign_key: {to_table: :badges}
  end
end
