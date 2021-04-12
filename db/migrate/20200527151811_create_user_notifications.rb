class CreateUserNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :user_notifications do |t|
      t.string :uuid, null: false, index: {unique: true}

      t.belongs_to :user, foreign_key: true, null: false, foreign_key: true
      t.belongs_to :track, foreign_key: true, null: true, foreign_key: true
      t.belongs_to :exercise, foreign_key: true, null: true, foreign_key: true

      t.column :status, :tinyint, null: false, default: 0
      t.string :path, null: false

      t.string :type, null: false
      t.integer :version, null: false
      t.json :params, null: false
      t.integer :email_status, null: false, default: 0, limit: 1

      t.string :uniqueness_key, null: false, index: {unique: true}
      t.json :rendering_data_cache, null: false

      t.datetime :read_at, null: true



      t.timestamps
    end
  end
end
