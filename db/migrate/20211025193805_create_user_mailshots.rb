class CreateUserMailshots < ActiveRecord::Migration[7.0]
  def change
    create_table :user_mailshots do |t|
      t.belongs_to :user, null: false
      t.string :mailshot_id, null: false
      t.integer :email_status, limit: 1, default: 0, null: false, index: true

      t.timestamps

      t.index [:user_id, :mailshot_id], unique: true
    end
  end
end
