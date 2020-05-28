class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.string :type, null: false
      t.integer :version, null: false
      t.json :params, null: false
      t.boolean :email_status, null: false, default: 0

      t.boolean :read, null: false, default: false

      t.timestamps
    end
  end
end
