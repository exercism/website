class CreateUserNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :user_notifications do |t|
      t.string :uuid, null: false, index: {unique: true}

      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :track, null: true, foreign_key: true
      t.belongs_to :exercise, null: true, foreign_key: true

      t.column :status, :tinyint, null: false, default: 0
      t.string :path, null: false

      t.string :type, null: false
      t.integer :version, null: false
      t.text :params, null: false
      t.integer :email_status, null: false, default: 0, limit: 1

      t.string :uniqueness_key, null: false, index: {unique: true}
      t.text :rendering_data_cache, null: false

      t.datetime :read_at, null: true

      t.timestamps
    end
  end
end
