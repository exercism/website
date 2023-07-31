class CreateUserReputationPeriods < ActiveRecord::Migration[7.0]
  def change
    create_table :user_reputation_periods do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.bigint :track_id, null: false

      t.column :about, :tinyint, null: false
      t.column :period, :tinyint, null: false
      t.column :category, :tinyint, null: false
      t.integer :reputation, null: false, default: 0

      t.string :user_handle, null: true

      t.boolean :dirty, null: false, default: true

      t.index [:user_id, :period, :category, :about, :track_id], unique: true, name: "unique"
      t.index [:period, :category, :about, :track_id, :reputation], name: "search-1"
      t.index [:period, :category, :about, :reputation], name: "search-2"
      t.index [:period, :category, :about, :track_id, :user_handle, :reputation], name: "search-3"
      t.index [:dirty], name: "sweeper"
    end
  end
end
