class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.string :type, null: false
      t.integer :version, null: false
      t.json :params, null: false
      t.integer :email_status, null: false, default: 0, limit: 1

      t.datetime :read_at, null: true

      t.timestamps
    end
  end
end
