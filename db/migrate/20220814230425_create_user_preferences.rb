class CreateUserPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :user_preferences do |t|
      t.belongs_to :user, foreign_key: true, index: { unique: true }
      t.boolean :auto_update_exercises, default: true, null: false

      t.timestamps
    end

    # Run on Bastion in production
    unless Rails.env.production?
      User.find_each(&:create_preferences)
    end
  end
end
